
# web (https and http) load balancers

The one or more load balancers created by this module are designed to listen out for **web traffic** on port 443 (https/tls) and port 80. <em>A courteous redirect response (to port 443) is issued to all requests received in http plain text ( on port 80 ).</em>

This load balancer is best suited for
- traffic from web browsers and mobile devices
- REST API traffic originating from apps

This load balancer assumes the existence of a domain name (or names) and corresponding SSL certificates resident within ACM (Amazon's Certificate Manager).

**Traffic is routed based on the request URI a.k.a path-based routing.**

## module usage

    module load-balancer {

        source  = "devops4me/web-load-balancers/aws"
        version = "~> 1.0.0"

        in_vpc_id            = "${ module.vpc-network.out_vpc_id }"
        in_subnet_ids        = "${ module.vpc-network.out_public_subnet_ids }"
        in_security_group_id = "${ module.security-group.out_security_group_id }"
        in_ip_addresses      = "${ aws_instance.server.*.private_ip }"
        in_ip_address_count  = 3
        in_front_end         = [ "http"  ]
        in_back_end          = [ "etcd" ]
        in_ecosystem         = "${ local.ecosystem_id }"
    }

    output dns_name{ value = "${ module.load-balancer.out_dns_name}" }


## module inputs

In order to create a load balancer you need security groups, subnets and you must specify whether it can be accessible on the internet, rather than just internally.

For internet accessible load balancers you must ensure that the VPC (parent of the subnets) **has an internet gateway** and **a route** to some kind of destination (the most open being 0.0.0.0/0).


| Input Variable | Type | Description         |
|:-------------- |:----:|:------------------- |
| **`in_vpc_id`** | string | The ID of the VPC containing all the back-end targets, subnets and security groups to route to. |
| **`in_security_group_id`** | string | The security group must be configured to permit the type of traffic the load balancer is routing. A **504 Gateway Time-out** error from your browser means a missing **security group rule** is blocking the traffic. |
| **`in_subnet_ids`** | List | Use public subnets for an externally accessible front-end even when the back-end targets are in private subnets. Use private subnets for internal load balancers. The IDs of the subnets that traffic will be routed to. **Important - traffic will not be routed to two or more subnets in the same availability zone.** |
| **`in_is_internal`** | Boolean | If true the load balancer's DNS name is private - if false the DNS name will be externally addressable. |
| **`in_ip_addresses`** | List | List of **private or public IP addresses** that the **load balancer's back-end** will route traffic to. If **internal [ in_is_internal = true ]**, then only private IP addresses **inside private subnets*** can be specified. |
| **`in_ssl_certificate_id`** | string | The ID of the SSL certificate living in the ACM (Amazon Certificate Manager) repository. |
| **`in_front_end`** | List | List of front end listener configurations for this load balancer like web (for http port 80) and ssl (for https port 443).  |
| **`in_back_end`** | List | List of back end target configuration for this load balancer **like etcd (for http port 2379)**, web (for http port 80) and ssl (for https port 443). |
| **`in_access_logs_bucket`** | string | The **name of the S3 bucket** to which the load balancer will post access logs. |
| **`in_ecosystem`** | string | the class name of the ecosystem being built here. |


---


## output variables

Here are the most popular **output variables** exported from this VPC and subnet creating module.

| Exported | Type | Example | Comment |
|:-------- |:---- |:------- |:------- |
| **`out_vpc_id`** | string | vpc-1234567890 | the **VPC id** of the just-created VPC
| **`out_rtb_id`** | string | "rtb-2468013579" | ID of the VPC's default route table
| **`out_subnet_ids`** | List of strings | [ "subnet-545123498798345", "subnet-83507325124987" ] | list of **all private and public** subnet ids
| **`out_private_subnet_ids`** | list( string ) | [ "subnet-545123498798345", "subnet-83507325124987" ] | list of **private** subnet ids
| **`out_public_subnet_ids`** | list( string ) |  [ "subnet-945873408204034", "subnet-8940202943031" ] | list of **public** subnet ids


---


## target group inputs | instance vs ip address

Currently the target group is hardcoded to HTTPS at port 443.

The health check is hardcoded

- to use **port 443**
- with the **root slash (/) path**
- so that **under 3 seconds** is a **healthy** threshold (green) and **more than 10 seconds** is **unhealthy** (red). In between is amber.
- to **time out** after 5 minutes
- to **check periodically** every 10 seconds
- to use **importantly** the **ip** type

There are two possible values for target type

- **instance** - targets will be specified by **ec2 instance ID** (the default)
- **ip** - targets will be specified by **private IP address** (in IPV4)

**Note that you can't specify targets for a target group using both instance IDs and IP addresses. If the target type is ip, specify IP addresses from the subnets of the virtual private cloud (VPC) for the target group, the RFC 1918 range (10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16), and the RFC 6598 range (100.64.0.0/10). Remember that you cannot specify publicly routable IP addresses.**



## Inputs for Network Interface (IP Address) Target Group Attachments

When AWS creates **instance (node) clusters** for the likes of Redis, Postgres, Kubernetes and ElasticSearch, it places ENIs (elastic network interfaces) that expose private IP addresses that load balancers can hook onto.

This method enables SSL termination (using Certificate Manager SSL certificates) whilst connecting to clusters through a load balancer.

The relevant network interfaces are queried for and when returned, we loop over them creating target group attachments that bind the target group to their private intra VPC IP addresses.

The port to use for each attachment is currently hardcoded to 443.

Splat syntax is used to retrieve the list of IP addresses, which are hen passed over for one to one creation of target group attachments.


## Inputs for Load Balancer Listeners

A load balancer listener **keeps an ear out** for incoming traffic **conforming to the specified protocol** and **arriving at the said port**.

AWS impose a limit of 50 listeners per load balancer.

Listeners **mostly forward traffic** on but they can also

- **terminate ssl**
- **reject traffic**
- **redirect traffic** based on path
- **redirect traffic** from http (port 80) to https (port 443)
- route traffic based on **path and/or host**
- **give a fixed response** (like for a heaalth check)

For a listener to terminate SSL, you must provide the ARN of the SSL certificate which is usually kept in certificate manager. However you can also import externally sourced SSLs certificate directly into the load balancer.


## Inputs for Load Balancer Listener Rules

The application load balancer can have many rules meaning we can route traffic to different places based on

- the **request path (url** text after first sole forward slash)
- the **host** that the request came from (info in http headers)


---


## Load Balancer Access Logs | 5 minutes | 60 minutes | none

We could write load balancer access logs to an S3 bucket every 5 minutes, 60 minutes or indeed never.

### Calculate Access Logs File Size

If the load balancer receives 5,000 requests per seconds how many file lines would result?

        5,000 x 60 x 60
        5,000 x 3,600
        5,000 x 3,600
        3,600,000 x 5
        18,000,000
        18 million lines

Now approximate the byte size of each line and then multiply out to determine roughly how big the file would be if produced

- every **5 minutes**
- every **hour**

