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
      allowed_values ['t2.micro', 't2.small']
    end
  end

  dynamic!(:ec2_instance, :sparkle) do
    properties do
      image_id ref!(:ami)
      instance_type ref!(:instance_type)
      key_name ref!(:key_name)
    end
  end

  outputs.sparkle_public_address do
    description 'Compute instance public address'
    value attr!(:sparkle_ec2_instance, :public_ip)
  end

end