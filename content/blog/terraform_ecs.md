+++
author = "yyh-gl"
categories = ["AWS", "Terraform", "ECS", "RDS"]
date = "2019-06-04"
description = ""
featured = "terraform_ecs/featured.png"
featuredalt = "画像がどこかへ逝ってしまったようだ…"
featuredpath = "date"
linktitle = ""
title = "【Terraform + ECS + RDS】Terraform で ECS環境構築してみた"
type = "post"

+++

<br>

---
# Terraform とは
---

最近流行りの IaC です。

つまり、コードベースでインフラリソースを管理するためのツールです。

中でもTerraform はクラウドに特化した IaC ツールという立ち位置です。

AWSやGCP, Azure などの他に[様々なクラウドプラットフォーム](https://www.terraform.io/docs/providers/index.html)に対応しています。


（ちなみに、Vagrant 開発元の [HashiCorp](https://www.hashicorp.com/) 社が開発しています）



---
# 今回やること
---

Terraform で AWS 上に下記のような環境を自動構築します。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/terraform_ecs/architecture.png" width="600">

<br>

ECS でデプロイされるサービスは ECR から引っ張ってくるようにします。

そして、そのサービスは Aurora を使うシステムを想定しています。

<u>【⚠注意⚠】上記構成はお金が発生します！ まったくもって無料枠ではありません！</u>

【⚠注意⚠】今回独自ドメインを使用していますが、ドメイン取得に関しては省略しています。


<br>

## 今回やる内容は…

僕が所属する会社の研修資料を参考に進めています。

資料を作成してくださった[@_y_ohgi](https://twitter.com/_y_ohgi)さんに感謝。

---
# 自動構築プロセス全体で使用する共通設定を定義
---

まず、 `main.tf` を作成し、以下のとおり共通設定を定義していきます。

```
# AWS を利用することを明示
provider "aws" {
    # リージョンを設定
    region = "ap-northeast-1"
}

# これから作成するリソースに付与する名前のプリフィックスを設定
# グローバル変数的な立ち位置で定義
variable "prefix" {
    default = "sample-project"
}
```

`provider` で使用するクラウドを指定することができます。

`variable` は変数定義です。

`${var.prefix}` と書くことで `default` で指定した内容が展開されます。

（次の定義ファイルでも変数が出てくるので、そこで使いかたを見てみてください。） 

なお、変数定義を別ファイルに切り出す方法もあるようですが、今回はやりません。

切り出す方法は[こちら](https://qiita.com/ringo/items/3af1735cd833fb80da75#%E5%A4%89%E6%95%B0%E6%88%A6%E7%95%A5%E8%A8%AD%E8%A8%88)が参考になると思います。

---
# Route53 の設定
---

`route53_acm.tf` を作成し、以下のとおり定義します。

内部で ACM に関する定義も行っています。

以降、クラウドプラットフォームに依存しない設定に関しては【解説】コメントで解説を行っています。
   
各 resource の定義内容に関しては コメントにあるURLを参考にしてください。

> 英語ではありますが、[公式ドキュメント](https://www.terraform.io/docs/providers/aws/index.html)がとても分かりやすいです

```
# ドメイン名の設定
variable "domain" {
    description = "「Route53で管理するドメイン」 などの説明文"
    type        = "string"

    # みなさんが持つドメイン名にしてください
    default = "example.com"
}

# Route53 Hosted Zone
# https://www.terraform.io/docs/providers/aws/d/route53_zone.html
# 【解説】data で始まっていますが、これは読み取り専用のリソースであることを示します。
# すでにクラウド上に存在するリソースの値を参照するために使用します。
data "aws_route53_zone" "main" {
    name         = "${var.domain}" # 変数を展開しているところ、ここです
    private_zone = false
}

# ACM
# https://www.terraform.io/docs/providers/aws/r/acm_certificate.html
# 【解説】resource は作成するリソースを定義する場所です。
resource "aws_acm_certificate" "main" {
    domain_name = "${var.domain}"

    validation_method = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}

# Route53 record
# ACMによる検証用レコード
# https://www.terraform.io/docs/providers/aws/r/route53_record.html
resource "aws_route53_record" "validation" {
    depends_on = ["aws_acm_certificate.main"]

    zone_id = "${data.aws_route53_zone.main.id}"

    ttl = 60

    name    = "${aws_acm_certificate.main.domain_validation_options.0.resource_record_name}"
    type    = "${aws_acm_certificate.main.domain_validation_options.0.resource_record_type}"
    records = ["${aws_acm_certificate.main.domain_validation_options.0.resource_record_value}"]
}

# ACM Validate
# https://www.terraform.io/docs/providers/aws/r/acm_certificate_validation.html
resource "aws_acm_certificate_validation" "main" {
    certificate_arn = "${aws_acm_certificate.main.arn}"

    validation_record_fqdns = ["${aws_route53_record.validation.0.fqdn}"]
}

# Route53 record
# https://www.terraform.io/docs/providers/aws/r/route53_record.html
resource "aws_route53_record" "main" {
    type = "A"

    name    = "${var.domain}"
    zone_id = "${data.aws_route53_zone.main.id}"

    alias = {
        name                   = "${aws_lb.main.dns_name}"
        zone_id                = "${aws_lb.main.zone_id}"
        evaluate_target_health = true
    }
}

# ALB Listener
# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
resource "aws_lb_listener" "https" {
    load_balancer_arn = "${aws_lb.main.arn}"

    certificate_arn = "${aws_acm_certificate.main.arn}"

    port     = "443"
    protocol = "HTTPS"

    default_action {
        type             = "forward"
        target_group_arn = "${aws_lb_target_group.main.id}"
    }
}

# ALB Listener Rule
# https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html
resource "aws_lb_listener_rule" "http_to_https" {
    listener_arn = "${aws_lb_listener.main.arn}"

    priority = 99

    action {
        type = "redirect"

        redirect {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }

    condition {
        field  = "host-header"
        values = ["${var.domain}"]
    }
}

# Security Group Rule
# https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
resource "aws_security_group_rule" "alb_https" {
    security_group_id = "${aws_security_group.alb.id}"

    type = "ingress"

    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
}
```

---
# VPCの設定
---

`vpc.tf` を以下のとおり定義します。

ここで、 `main.tf` で定義した変数が大活躍します。

```
# VPC
# https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "main" {
	cidr_block = "10.0.0.0/16"

	tags = {
		Name = "${var.prefix}-vpc"
	}
}

# Public Subnet
# https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "public_1a" {
	# 先程作成したVPCを参照し、そのVPC内にSubnetを立てる
	vpc_id = "${aws_vpc.main.id}"

	# Subnetを作成するAZ
	availability_zone = "ap-northeast-1a"

	cidr_block = "10.0.1.0/24"

	tags = {
		Name = "${var.prefix}-public-1a"
	}
}

resource "aws_subnet" "public_1c" {
	vpc_id = "${aws_vpc.main.id}"

	availability_zone = "ap-northeast-1c"

	cidr_block = "10.0.2.0/24"

	tags = {
		Name = "${var.prefix}-public-1c"
	}
}

resource "aws_subnet" "public_1d" {
	vpc_id = "${aws_vpc.main.id}"

	availability_zone = "ap-northeast-1d"

	cidr_block = "10.0.3.0/24"

	tags = {
		Name = "${var.prefix}-public-1d"
	}
}

# Private Subnets
resource "aws_subnet" "private_1a" {
	vpc_id = "${aws_vpc.main.id}"

	availability_zone = "ap-northeast-1a"

	cidr_block = "10.0.10.0/24"

	tags = {
		Name = "${var.prefix}-private-1a"
	}
}

resource "aws_subnet" "private_1c" {
	vpc_id = "${aws_vpc.main.id}"

	availability_zone = "ap-northeast-1c"

	cidr_block = "10.0.20.0/24"

	tags = {
		Name = "${var.prefix}-private-1c"
	}
}

resource "aws_subnet" "private_1d" {
	vpc_id = "${aws_vpc.main.id}"

	availability_zone = "ap-northeast-1d"

	cidr_block = "10.0.30.0/24"

	tags = {
		Name = "${var.prefix}-private-1d"
	}
}

# Internet Gateway
# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
resource "aws_internet_gateway" "main" {
	vpc_id = "${aws_vpc.main.id}"

	tags = {
		Name = "${var.prefix}-igw"
	}
}

# Elasti IP
# NAT Gateway には1つの Elastic IP が必要なので作成
# https://www.terraform.io/docs/providers/aws/r/eip.html
resource "aws_eip" "nat_1a" {
	vpc = true

	tags = {
		Name = "${var.prefix}-eip-for-natgw-1a"
	}
}

# NAT Gateway
# https://www.terraform.io/docs/providers/aws/r/nat_gateway.html
resource "aws_nat_gateway" "nat_1a" {
	subnet_id     = "${aws_subnet.public_1a.id}" # NAT Gatewayを配置するSubnetを指定
	allocation_id = "${aws_eip.nat_1a.id}"       # 紐付けるElasti IP

	tags = {
		Name = "${var.prefix}-natgw-1a"
	}
}

resource "aws_eip" "nat_1c" {
	vpc = true

	tags = {
		Name = "${var.prefix}-eip-for-natgw-1c"
	}
}

resource "aws_nat_gateway" "nat_1c" {
	subnet_id     = "${aws_subnet.public_1c.id}"
	allocation_id = "${aws_eip.nat_1c.id}"

	tags = {
		Name = "${var.prefix}-natgw-1c"
	}
}

resource "aws_eip" "nat_1d" {
	vpc = true

	tags = {
		Name = "${var.prefix}-eip-for-natgw-1d"
	}
}

resource "aws_nat_gateway" "nat_1d" {
	subnet_id     = "${aws_subnet.public_1d.id}"
	allocation_id = "${aws_eip.nat_1d.id}"

	tags = {
		Name = "${var.prefix}-natgw-1d"
	}
}

# Route Table
# https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "public" {
	vpc_id = "${aws_vpc.main.id}"

	tags = {
		Name = "${var.prefix}-public-route-table"
	}
}

# Route
# https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "public" {
	destination_cidr_block = "0.0.0.0/0"
	route_table_id         = "${aws_route_table.public.id}"
	gateway_id             = "${aws_internet_gateway.main.id}"
}

# Association
# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "public_1a" {
	subnet_id      = "${aws_subnet.public_1a.id}"
	route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_1c" {
	subnet_id      = "${aws_subnet.public_1c.id}"
	route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_1d" {
	subnet_id      = "${aws_subnet.public_1d.id}"
	route_table_id = "${aws_route_table.public.id}"
}

# Route Table (Private)
# https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "private_1a" {
	vpc_id = "${aws_vpc.main.id}"

	tags = {
		Name = "${var.prefix}--private-1a"
	}
}

resource "aws_route_table" "private_1c" {
	vpc_id = "${aws_vpc.main.id}"

	tags = {
		Name = "${var.prefix}--private-1c"
	}
}

resource "aws_route_table" "private_1d" {
	vpc_id = "${aws_vpc.main.id}"

	tags = {
		Name = "${var.prefix}--private-1d"
	}
}

# Route (Private)
# https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "private_1a" {
	destination_cidr_block = "0.0.0.0/0"
	route_table_id         = "${aws_route_table.private_1a.id}"
	nat_gateway_id         = "${aws_nat_gateway.nat_1a.id}"
}

resource "aws_route" "private_1c" {
	destination_cidr_block = "0.0.0.0/0"
	route_table_id         = "${aws_route_table.private_1c.id}"
	nat_gateway_id         = "${aws_nat_gateway.nat_1c.id}"
}

resource "aws_route" "private_1d" {
	destination_cidr_block = "0.0.0.0/0"
	route_table_id         = "${aws_route_table.private_1d.id}"
	nat_gateway_id         = "${aws_nat_gateway.nat_1d.id}"
}

# Association (Private)
# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "private_1a" {
	subnet_id      = "${aws_subnet.private_1a.id}"
	route_table_id = "${aws_route_table.private_1a.id}"
}

resource "aws_route_table_association" "private_1c" {
	subnet_id      = "${aws_subnet.private_1c.id}"
	route_table_id = "${aws_route_table.private_1c.id}"
}

resource "aws_route_table_association" "private_1d" {
	subnet_id      = "${aws_subnet.private_1d.id}"
	route_table_id = "${aws_route_table.private_1d.id}"
}
```


---
# ロードバランサの設定
---

次は ALB の定義を作成します。

`alb.tf` に以下のとおり定義します。

```
# SecurityGroup
# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "alb" {
    name        = "${var.prefix}-alb"
    description = "${var.prefix} alb"
    vpc_id      = "${aws_vpc.main.id}"

    # セキュリティグループ内のリソースからインターネットへのアクセスを許可する
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.prefix}-alb"
    }
}

# SecurityGroup Rule
# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group_rule" "alb_http" {
    security_group_id = "${aws_security_group.alb.id}"

    # セキュリティグループ内のリソースへインターネットからのアクセスを許可する
    type = "ingress"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
}

# ALB
# https://www.terraform.io/docs/providers/aws/d/lb.html
resource "aws_lb" "main" {
    load_balancer_type = "application"
    name               = "${var.prefix}"

    security_groups = ["${aws_security_group.alb.id}"]
    subnets         = ["${aws_subnet.public_1a.id}", "${aws_subnet.public_1c.id}", "${aws_subnet.public_1d.id}"]
}

# Listener
# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
resource "aws_lb_listener" "main" {
    # HTTPでのアクセスを受け付ける
    port              = "80"
    protocol          = "HTTP"

    # ALBのarnを指定します。
    load_balancer_arn = "${aws_lb.main.arn}"

    # "ok" という固定レスポンスを設定する
    default_action {
        type             = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            status_code  = "200"
            message_body = "ok"
        }
    }
}
```

---
# ECSの設定
---

`ecs.tf` はこんな感じです。

```
resource "aws_iam_role" "ecs_task_execution_role" {
	name = "ecs_task_execution_role"
	assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-policy" {
	role = "${aws_iam_role.ecs_task_execution_role.name}"
	policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr-read-policy" {
	role = "${aws_iam_role.ecs_task_execution_role.name}"
	policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# Task Definition
# https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html
resource "aws_ecs_task_definition" "main" {
	family = "${var.prefix}"

	# データプレーンの選択
	requires_compatibilities = ["FARGATE"]

	# ECSタスクが使用可能なリソースの上限
	# タスク内のコンテナはこの上限内に使用するリソースを収める必要があり
	# メモリが上限に達した場合OOM Killer にタスクがキルされる
	cpu    = "256"
	memory = "512"

	# ECSタスクのネットワークドライバ
	# Fargateを使用する場合は"awsvpc"決め打ち
	network_mode = "awsvpc"

	# ECRからDocker ImageをPULLするための権限
	execution_role_arn = "${aws_iam_role.ecs_task_execution_role.arn}"

	# 起動するコンテナの定義
	# 【解説1】JSONでコンテナを定義します
	# 【解説2】JSON内の environment で環境変数を設定します。
	# environment ではデータベースのホストを設定しています。
	# 機密情報（次の項目で設定します）として登録するか迷いましたが、
	# 機密情報だとパラメータストアを経由する必要があり、
	# 手動設定が必要になるので、環境変数にしました。
	# プライベートサブネットに入ってるので大丈夫だと考えています。
	# 【解説3】JSON内の secrets で機密情報を設定します。
	# 今回はよく使いそうなものを適当に定義しました。
	# 機密情報 は System Manager のパラメータストアから持ってきます。
	container_definitions = <<EOL
[
  {
    "name": "<your repository name>",
    "image": "<your image name>",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "environment": [
        {
            "name": "MYSQL_HOST",
            "value": "${aws_rds_cluster.this.endpoint}"
        }
    ],
    "secrets": [
      {
        "name": "MYSQL_PASSWORD",
        "valueFrom": "arn:aws:ssm:ap-northeast-1:910114278227:parameter/MYSQL_PASSWORD"
      },
      {
        "name": "MYSQL_USER",
        "valueFrom": "arn:aws:ssm:ap-northeast-1:910114278227:parameter/MYSQL_USER"
      },
      {
        "name": "MYSQL_DATABASE",
        "valueFrom": "arn:aws:ssm:ap-northeast-1:910114278227:parameter/MYSQL_DATABASE"
      },
      {
        "name": "AWS_ACCESS_KEY",
        "valueFrom": "arn:aws:ssm:ap-northeast-1:910114278227:parameter/ACCESS_KEY"
      },
      {
        "name": "AWS_SECRET_KEY",
        "valueFrom": "arn:aws:ssm:ap-northeast-1:910114278227:parameter/SECRET_KEY"
      },
      {
        "name": "S3_BUCKET_NAME",
        "valueFrom": "arn:aws:ssm:ap-northeast-1:910114278227:parameter/S3_BUCKET_NAME"
      },
      {
        "name": "AUTH_SECRET",
        "valueFrom": "arn:aws:ssm:ap-northeast-1:910114278227:parameter/AUTH_SECRET"
      }
    ]
  }
]
EOL
}

# ECS Cluster
# https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html
resource "aws_ecs_cluster" "main" {
	name = "${var.prefix}"
}

# ELB Target Group
# https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
resource "aws_lb_target_group" "main" {
	name = "${var.prefix}"

	# ターゲットグループを作成するVPC
	vpc_id = "${aws_vpc.main.id}"

	# ALBからECSタスクのコンテナへトラフィックを振り分ける設定
	port        = 8080
	protocol    = "HTTP"
	target_type = "ip"

	# コンテナへの死活監視設定
	health_check = {
		port = 8080
		path = "/health"
	}
}

# ALB Listener Rule
# https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html
resource "aws_lb_listener_rule" "main" {
	# ルールを追加するリスナー
	listener_arn = "${aws_lb_listener.main.arn}"

	# 受け取ったトラフィックをターゲットグループへ受け渡す
	action {
		type             = "forward"
		target_group_arn = "${aws_lb_target_group.main.id}"
	}

	# ターゲットグループへ受け渡すトラフィックの条件
	condition {
		field  = "path-pattern"
		values = ["*"]
	}
}

# SecurityGroup
# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "ecs" {
	name        = "${var.prefix}-ecs"
	description = "${var.prefix} ecs"

	# セキュリティグループを配置するVPC
	vpc_id      = "${aws_vpc.main.id}"

	# セキュリティグループ内のリソースからインターネットへのアクセス許可設定
	# 今回の場合DockerHubへのPullに使用する。
	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "${var.prefix}-ecs"
	}
}

# SecurityGroup Rule
# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group_rule" "ecs" {
	security_group_id = "${aws_security_group.ecs.id}"

	# インターネットからセキュリティグループ内のリソースへのアクセス許可設定
	type = "ingress"

	# TCPでの80ポートへのアクセスを許可する
	from_port = 80
	to_port   = 8080
	protocol  = "tcp"

	# 同一VPC内からのアクセスのみ許可
	cidr_blocks = ["10.0.0.0/16"]
}

# ECS Service
# https://www.terraform.io/docs/providers/aws/r/ecs_service.html
resource "aws_ecs_service" "main" {
	name = "${var.prefix}"

	# 依存関係の記述。
	# "aws_lb_listener_rule.main" リソースの作成が完了するのを待ってから当該リソースの作成を開始する。
	# "depends_on" は "aws_ecs_service" リソース専用のプロパティではなく、Terraformのシンタックスのため他の"resource"でも使用可能
	depends_on = ["aws_lb_listener_rule.main"]

	# 当該ECSサービスを配置するECSクラスターの指定
	cluster = "${aws_ecs_cluster.main.name}"

	# データプレーンとしてFargateを使用する
	launch_type = "FARGATE"

	# ECSタスクの起動数を定義
	desired_count = "1"

	# 起動するECSタスクのタスク定義
	task_definition = "${aws_ecs_task_definition.main.arn}"

	# ECSタスクへ設定するネットワークの設定
	network_configuration = {
		# タスクの起動を許可するサブネット
		subnets         = ["${aws_subnet.private_1a.id}", "${aws_subnet.private_1c.id}", "${aws_subnet.private_1d.id}"]
		# タスクに紐付けるセキュリティグループ
		security_groups = ["${aws_security_group.ecs.id}"]
	}

	# ECSタスクの起動後に紐付けるELBターゲットグループ
	load_balancer = [
		{
			target_group_arn = "${aws_lb_target_group.main.arn}"
			container_name   = "<your container name>"
			container_port   = "8080"
		},
	]
}
```

機密情報を渡すところに関しては [こちら](https://khigashigashi.hatenablog.com/entry/2018/08/28/214417) の記事が分かりやすいです。

機密情報として設定する値は System Manager のパラメータストアにセットする必要があります。


---
# RDSの設定
---

最後に `rds.tf` を以下のとおり定義します。

```
# SSM Parameter data source
# https://www.terraform.io/docs/providers/aws/d/ssm_parameter.html
data "aws_ssm_parameter" "database_name" {
	name = "MYSQL_DATABASE"
}

data "aws_ssm_parameter" "database_user" {
	name = "MYSQL_USER"
}

data "aws_ssm_parameter" "database_password" {
	name = "MYSQL_PASSWORD"
}

# 【解説】locals は名前のとおりローカル変数です。
# variables だと `${}` 展開できないのでこちらを使用しました。
# 他にやり方があれば教えてほしいです。
locals {
	name = "${var.prefix}-rds-mysql"
}

resource "aws_security_group" "this" {
	name        = "${local.name}"
	description = "${local.name}"

	vpc_id = "${aws_vpc.main.id}"

  egress {
	  from_port   = 0
	  to_port     = 0
	  protocol    = "-1"
	  cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
	  Name = "${local.name}"
  }
}

resource "aws_security_group_rule" "mysql" {
	security_group_id = "${aws_security_group.this.id}"

	type = "ingress"

	from_port   = 3306
	to_port     = 3306
	protocol    = "tcp"
	cidr_blocks = ["10.0.0.0/16"]
}

resource "aws_db_subnet_group" "this" {
	name        = "${local.name}"
	description = "${local.name}"
	subnet_ids  = [
		"${aws_subnet.private_1a.id}",
		"${aws_subnet.private_1c.id}",
		"${aws_subnet.private_1d.id}",
	]
}

# RDS Cluster
# https://www.terraform.io/docs/providers/aws/r/rds_cluster.html
resource "aws_rds_cluster" "this" {
	cluster_identifier = "${local.name}"

	db_subnet_group_name   = "${aws_db_subnet_group.this.name}"
	vpc_security_group_ids = ["${aws_security_group.this.id}"]

	engine = "aurora-mysql"
	port   = "3306"

	database_name   = "${data.aws_ssm_parameter.database_name.value}"
	master_username = "${data.aws_ssm_parameter.database_user.value}"
	master_password = "${data.aws_ssm_parameter.database_password.value}"

	# RDSインスタンス削除時のスナップショットの取得強制を無効化
	skip_final_snapshot = true

	# 使用する Parameter Group を指定
	db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.this.name}"
}

# RDS Cluster Instance
# https://www.terraform.io/docs/providers/aws/r/rds_cluster_instance.html
resource "aws_rds_cluster_instance" "this" {
	identifier         = "${local.name}"
	cluster_identifier = "${aws_rds_cluster.this.id}"

	engine = "aurora-mysql"

	instance_class = "db.t3.small"
}

# RDS Cluster Parameter Group
# https://www.terraform.io/docs/providers/aws/r/rds_cluster_parameter_group.html
# 日本時間に変更 & 日本語対応のために文字コードを変更
resource "aws_rds_cluster_parameter_group" "this" {
	name   = "${local.name}"
	family = "aurora-mysql5.7"

	parameter {
		name  = "time_zone"
		value = "Asia/Tokyo"
	}

	parameter {
		name  = "character_set_client"
		value = "utf8mb4"
	}

	parameter {
		name  = "character_set_connection"
		value = "utf8mb4"
	}

	parameter {
		name  = "character_set_database"
		value = "utf8mb4"
	}

	parameter {
		name  = "character_set_results"
		value = "utf8mb4"
	}

	parameter {
		name  = "character_set_server"
		value = "utf8mb4"
	}
}

# terraform applyコマンド完了時にコンソールにエンドポイントを表示
# 【解説】もしエンドポイントも機密情報として扱うのであれば
# ここで表示されたエンドポイントをパラメータストアに格納すればよい。
# 今回は紹介のために使用。
output "rds_endpoint" {
	value = "${aws_rds_cluster.this.endpoint}"
}
```

---
# テスト
---

上記で作成してきた tfファイルたちを同じディレクトリに格納し、

そのディレクトリ内で下記コマンドを実行します。

`AWS_ACCESS_KEY_ID=<your access key> AWS_SECRET_ACCESS_KEY=<your secret access key> terraform apply`

アクセスキーとシークレットキーは IAM から取得してください。

terraform コマンドが入ってない人は brew やらなんやらでインストールお願いします。

<br>

実行して（かなり時間がかかりますが）下記のように出力されたら成功です！


<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/terraform_ecs/terraform_apply_success.png" width="600">

<br>

削除もやってみましょう。

`AWS_ACCESS_KEY_ID=<your access key> AWS_SECRET_ACCESS_KEY=<your secret access key> terraform destroy`

こちらもかなり時間がかかりますが、下記のようにリソースが削除されると思います。

<img src="https://yyh-gl.github.io/tech-blog/img/tech-blog/2019/06/terraform_ecs/terraform_destroy_success.png" width="600">


<br>

## tfファイルの実行順

tfファイル内で作成したリソースから取得した値を他のリソースで使用する場面がありました。

ここで気になるのが tfファイルの実行順番です。

実行順番次第では、取得したい値がまだできていないということも起こりそうです。

これに関して、結論から言うと僕たちが順番を考える必要はありません。

tfファイルを適当にディレクトリに突っ込んだだけですが、

terraform 側でよしなに順番を決めてやってくれます。

すごい。


---
# まとめ
---

Terraformすごい。

自動でここまでできてしまう。

しかも、コードで定義するからバージョン管理できる。

差分チェックできる。

「分かる、こいつ強い。」


<br>

今回はファイル分割しただけですが、モジュール分割とかもできるようなので今後やっていきます。

bbhogea
