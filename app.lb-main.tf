
/*
 | --
 | -- This load balancer terraform package stands out due to its ability to
 | -- create a set of load balancers given a list of container end point
 | -- targets to balance.
 | --
 | -- At its architectural heart the application load balancer is designed
 | -- to separate interface from implementation.
 | --
 | -- The interface listens for web traffic on both port 80 and 443 (tls).
 | -- The implementation at the back end is handled by the target group
 | -- which is usually a collection (cluster) of interconnected services.
 | --
*/
resource aws_alb alb {

    count = length( var.in_service_names )

    name               = "${ element( var.traffic[ var.in_service_names[ count.index ] ], 3 ) }-${ var.in_ecosystem_name }-${ var.in_tag_timestamp }"
    security_groups    = var.in_security_group_ids
    subnets            = var.in_subnet_ids
    internal           = false
    load_balancer_type = "application"
    idle_timeout       = 60
    ip_address_type    = "ipv4"

    enable_deletion_protection = false

    tags = {

        Name = "load-balancer-${ element( var.traffic[ var.in_service_names[ count.index ] ], 3 ) }-${ var.in_ecosystem_name }-${ var.in_tag_timestamp }"
        Class = var.in_ecosystem_name
        Instance = "${ var.in_ecosystem_name }-${ var.in_tag_timestamp }"
        Desc   = "This ${ element( var.traffic[ var.in_service_names[ count.index ] ], 2 ) } external load balancer for ${ var.in_ecosystem_name } ${ var.in_tag_description }"
    }

}


/*
 | --
 | -- Listeners are the front-end (ears) of our load balancer setup. This
 | -- https (tls) listener listens for connections from clients on port 443
 | -- and presents the tls certificate looked up from ACM (AWS Cert Manager)
 | -- to the client making the request.
 | --
 | -- The default action forwards the request to the appropriate target.
 | --
*/
resource aws_alb_listener https {

    count = length( var.in_service_names )

    load_balancer_arn = element( aws_alb.alb.*.id, count.index )
    protocol          = "HTTPS"
    port              = 443
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = element( data.aws_acm_certificate.tls.*.arn, count.index )

    default_action {

        target_group_arn = element( aws_alb_target_group.alb_targets.*.arn, count.index )
	type = "forward"
    }
}


/*
 | --
 | -- These http listeners are provided for courtesy. They never forward the
 | -- http (port 80) requests to the back-end.
 | --
 | -- Instead, they respond to the client with a (status code 301) redirect
 | -- action - telling them to come back using https on port 443.
 | --
*/
resource aws_alb_listener http {

    count = length( var.in_service_names )

    load_balancer_arn = element( aws_alb.alb.*.id, count.index )
    protocol          = "HTTP"
    port              = 80

    default_action {

        type = "redirect"
        redirect {

            port        = 443
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}



/*
 | --
 | -- Target groups are the back-end of our load balancer. They need to
 | -- know what port and protocol is being used and they derive this from
 | -- the traffic variable object.
 | --
 | -- Each target group expects a URI path with no leading forward slash
 | -- that indicates how to assess health. A healthy target should return
 | -- a HTTP status code 200.
 | --
*/
resource aws_alb_target_group alb_targets {

    count = length( var.in_service_names )

    vpc_id      = var.in_vpc_id
    name        = "${ var.in_ecosystem_name }-${ element( var.traffic[ var.in_service_names[ count.index ] ], 3 ) }-${ var.in_tag_timestamp }"
    protocol    = element( var.traffic[ var.in_service_names[ count.index ] ], 0 )
    port        = element( var.traffic[ var.in_service_names[ count.index ] ], 1 )
    target_type = "instance"

    health_check {
        healthy_threshold   = 3
        unhealthy_threshold = 3
        protocol            = "HTTP"
        timeout             = 10
        path                = "/${ var.in_health_check_uris[ count.index ] }"
        interval            = 60
        matcher             = "200,201,202,304"
    }

    tags = {

        Name   = "${ var.in_ecosystem_name }-${ element( var.traffic[ var.in_service_names[ count.index ] ], 3 ) }-traffic-${ var.in_tag_timestamp }-${ count.index }"
        Class = var.in_ecosystem_name
        Instance = "${ var.in_ecosystem_name }-${ var.in_tag_timestamp }"
        Desc   = "This load balancer backend targeting ${ element( var.traffic[ var.in_service_names[ count.index ] ], 2 ) } traffic for ${ var.in_ecosystem_name } ${ var.in_tag_description }"
    }

}


/*
 | --
 | -- This data source flicks through the certificates within AWS Cert Manager
 | -- to find the one that is registered against the particular Route53 domain
 | -- name at the present iterative position.
 | --
*/
data aws_acm_certificate tls {

    count    = length( var.in_dns_names )
    domain   = var.in_dns_names[ count.index ]
    statuses = [ "ISSUED" ]

}
