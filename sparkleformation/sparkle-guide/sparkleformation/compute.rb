SparkleFormation.new(:compute, :provider => :aws) do
  AWSTemplateFormatVersion '2010-09-09'
  description 'Sparkle Guide Compute Template'

  parameters do
    ami do
      type 'String'
      default 'ami-0d7ed3ddb85b521a6'
    end

    key_name.type 'String'
    
    instance_type do
      type 'String'
      default 't2.micro'
      allowed_values registry!(:instance_type)
    end
  end

  dynamic!(:ec2_instance, :web) do
    properties do
      image_id ref!(:ami)
      instance_type ref!(:instance_type)
      key_name ref!(:key_name)
      subnet_id ref!(:public_ec2_subnet)
    end
  end

  dynamic!(:ec2_vpc, :my) do
    properties do
      cidr_block "10.0.0.0/16"
    end
  end

  dynamic!(:ec2_subnet, :public) do
    properties do
      vpc_id ref!(:my_ec2_vpc)
      cidr_block "10.0.10.0/24"
      map_public_ip_on_launch true
      availability_zone "ap-northeast-1a"
    end
  end

  outputs.sparkle_public_address do
    description 'Compute instance public address'
    value attr!(:web_ec2_instance, :public_ip)
  end

end