#!/bin/bash  

chaturl=$(kubectl get svc | grep chatgpt-client-lb | awk '{print $4}')
node_ip=$(kubectl get nodes -o=jsonpath='{.items[0].status.addresses[0].address}')
smtp_port=$(kubectl --namespace email get svc mailhog -o=jsonpath="{.spec.ports[?(@.name=='tcp-smtp')].nodePort}")

while true
do
    listOfBadPods=$(kubectl get pod | grep -v NAME | grep -v Running | grep -v Completed | awk '{print $1}')
    for i in $listOfBadPods
    do
	podname=$(echo $i) ; 
        error=$(kubectl get pod $i | grep -v STATUS | awk '{print $3}')
	describe_pod=$(kubectl describe pod $i)
	args=$(echo "One of my kubernetes pods reports $error .What does this mean ?")
	encoded_string=$(printf "%s" "$args" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\&/%26/g' -e "s/'/%27/g" -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g')

	chat_response=$(curl -s "{$chaturl}/${encoded_string}")
	mailto=pragerhome@gmail.com
	mail_subject=$(echo "Pod $i is failing for reason $error")
	cat << EOF > /tmp/mail-details.txt
Hi $mailto ! 

"$mail_subject"

Pod details are: 
"$describe_pod"

ChatGPT says on this: 
$chat_response 

Regards 
The Pod Monitor  
EOF

subject="$mail_subject"
    /usr/bin/perl swaks -f "ThePodMonitor@marks-minikube.com" -t local@me -s $node_ip -p $smtp_port --header "Subject: $subject" --body /tmp/mail-details.txt 

    done
    sleep 60
done
