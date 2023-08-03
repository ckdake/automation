resource "aws_kms_key" "management" {
    description = "This key is used to encrypt everything related to the management account"
    enable_key_rotation = true
}

resource "aws_kms_alias" "management" {
    name = "alias/management"
    target_key_id = aws_kms_key.management.id
}