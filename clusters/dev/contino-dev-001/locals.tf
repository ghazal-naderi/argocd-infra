locals {
  # The cluster and AWS account names are inferred from the parent directory name
  split_path_list               = split("/", abspath(path.module))
  split_path_account_name_index = length(local.split_path_list) - 2
  split_path_cluster_name_index = length(local.split_path_list) - 1

  account_name = element(local.split_path_list, local.split_path_account_name_index)
  cluster_name = element(local.split_path_list, local.split_path_cluster_name_index)

  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name
}
