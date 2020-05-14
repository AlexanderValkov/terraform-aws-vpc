region         = "us-east-1"
vpc_cidr_block = "10.0.0.0/16"
vpc_tag_Name   = "prod"

subnet = {
  public = [
    {
      az_postfix      = "a"
      subnet_tag_Name = "public_a"
    },
    {
      az_postfix      = "b"
      subnet_tag_Name = "public_b"
    },
    {
      az_postfix      = "c"
      subnet_tag_Name = "public_c"
    }
  ]
  private = [
    {
      az_postfix      = "a"
      subnet_tag_Name = "private_a"
    },
    {
      az_postfix      = "b"
      subnet_tag_Name = "private_b"
    },
    {
      az_postfix      = "c"
      subnet_tag_Name = "private_c"
    }
  ]
}
