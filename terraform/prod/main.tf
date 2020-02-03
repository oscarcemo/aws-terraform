## VPC

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "simple-vpc"

  cidr = "${var.vpc_cidr}"

  azs             = ["eu-west-1a"]
  private_subnets = []
  public_subnets  = ["${var.subnet_cidr}"]

  enable_ipv6 = false

  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = false

  tags = {
    Owner       = "user"
    Environment = "prod"
  }

  vpc_tags = {
    Name = "vpc-aws-demo"
  }
}

## SECURITY GROUP SSH

module "ssh_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 3.0"

  name        = "ssh-sg"
  description = "Security group with SSH open"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

## KEY PAIR

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"
  key_name   = "deployer"
  public_key = "${var.public_key}"
}

## LAUNCH CONFIGURATION AND AUTOSCALING GROUP

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"
  name = "aws-demo-with-alb"

  # Launch configuration
  #
  # launch_configuration = "my-existing-launch-configuration" # Use the existing launch configuration
  # create_lc = false # disables creation of launch configuration
  lc_name = "demo-aws-lc"

  image_id        = "${data.aws_ami.ami.id}"
  instance_type   = "t2.micro"
  security_groups = ["${module.ssh_security_group.this_security_group_id}"]
  load_balancers  = ["${module.elb.this_elb_id}"]
  key_name        = "${module.key_pair.this_key_pair_key_name}"

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "8"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "8"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "demo-aws-asg"
  vpc_zone_identifier       = "${module.vpc.public_subnets}"
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "prod"
      propagate_at_launch = true
    },
  ]
}

module "elb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "elb-sg"
  description = "Security group for example usage with ELB"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

module "elb" {
  source = "terraform-aws-modules/elb/aws"

  name = "elb-example"

  subnets         = "${module.vpc.public_subnets}"
  security_groups = ["${module.elb_security_group.this_security_group_id}","${module.ssh_security_group.this_security_group_id}"]
  internal        = false

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
    target              = "HTTP:80/health"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = {
    Owner       = "user"
    Environment = "prod"
  }
}
