--Change role
use role dev_admin;

create warehouse load_wh
    with
    warehouse_size = "xsmall"
    warehouse_type = "standard"
    auto_suspend = 300
    auto_resume = true
    min_cluster_count = 1
    max_cluster_count = 1
    scaling_policy = "standard";

show warehouses;