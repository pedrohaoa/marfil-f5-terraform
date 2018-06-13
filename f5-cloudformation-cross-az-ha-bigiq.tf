resource "aws_cloudformation_stack" "f5-cluster-cross-az-ha-bigiq" {
  name         = "ha-${var.emailidsan}-${aws_vpc.terraform-vpc.id}"
  capabilities = ["CAPABILITY_IAM"]
 /* 
  provisioner "local-exec" {
    when    = "destroy"
    command = "lab-cleanup"
  }
  */
  parameters {
    #NETWORKING CONFIGURATION

    Vpc                          = "${aws_vpc.terraform-vpc.id}"
    managementSubnetAz1          = "${aws_subnet.f5-management-a.id}"
    managementSubnetAz2          = "${aws_subnet.f5-management-b.id}"
    # bigipManagementSecurityGroup = "${aws_security_group.f5_management.id}"
    subnet1Az1                   = "${aws_subnet.public-a.id}"
    subnet1Az2                   = "${aws_subnet.public-b.id}"
    # bigipExternalSecurityGroup   = "${aws_security_group.f5_data.id}"

    #INSTANCE CONFIGURATION

    imageName            = "Good"
    instanceType         = "m4.large"
    restrictedSrcAddress = "0.0.0.0/0"
    sshKey               = "${var.aws_keypair}"
    restrictedSrcAddressApp = "0.0.0.0/0"
    ntpServer            = "0.pool.ntp.org"

    #BIG-IQ LICENSING CONFIGURATION

    bigIqAddress         = "${var.bigIqLicenseManager}"
    bigIqUsername        = "admin"
    bigIqPasswordS3Arn   = "arn:aws:s3:::f5-public-cloud/passwd"
    bigIqLicensePoolName = "${var.bigIqLicensePoolName}"
    bigIqLicenseSkuKeyword1 = "LTM"
    bigIqLicenseUnitOfMeasure = "yearly"

    #TAGS

    application = "f5app"
    environment = "f5env"
    group       = "ltm"
    owner       = "f5owner"
    costcenter  = "f5costcenter"
  }

  #CloudFormation templates triggered from Terraform must be hosted on AWS S3. Experimental hosted in non-canonical S3 bucket.
  template_url = "https://s3.amazonaws.com/f5-public-cloud/f5-existing-stack-across-az-cluster-bigiq-2nic-bigip_v3.1.0.template"
}
