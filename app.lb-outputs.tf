
################ ################################################# ########
################ Module [[[load balancer]]] Output Variables List. ########
################ ################################################# ########


### ################################# ###
### [[output]] out_load_balancer_urls ###
### ################################# ###

output out_load_balancer_urls {

    value = aws_alb.alb.*.dns_name

}


### ############################### ###
### [[output]] out_target_group_ids ###
### ############################### ###

output out_target_group_ids {

    value = aws_alb_target_group.alb_targets.*.id

}


### ############################ ###
### [[output]] out_http_listener ###
### ############################ ###

output out_http_listener {

    value = aws_alb_listener.http

}


### ############################# ###
### [[output]] out_https_listener ###
### ############################# ###

output out_https_listener {

    value = aws_alb_listener.https

}
