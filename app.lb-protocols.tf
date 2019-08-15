
/*
 | --
 | -- This object contains a mapping of common load balancer traffic
 | -- protocols with the preferred ports and a small description that
 | -- forms part of the listener and target group tags.
 | --
 | -- If reusing this terraform module feel free to pass in a traffic
 | -- object that is suited to the infrastructure being provisioned.
 | --
*/
variable traffic {

    description = "Load balancer traffic protocols for front and listeners and back end targets."

    type = object({
        web = list(string)
    	nginx = list(string)
	jenkins = list(string)
	sonar = list(string)
	docker = list(string)
    })

    default = {
        web     = [ "HTTP" ,     80,  "internet www port 80"      ,  "web"     ]
        nginx   = [ "HTTP" ,     80,  "nginx port 80"             ,  "nginx"   ]
        jenkins = [ "HTTP" ,   8080,  "jenkins port 8080"         ,  "jenkins" ]
        sonar   = [ "HTTP" ,   9000,  "sonarqube port 9000"       ,  "sonar"   ]
        docker  = [ "HTTP" ,   5000,  "docker registry port 5000" ,  "docker"  ]
    }

}
