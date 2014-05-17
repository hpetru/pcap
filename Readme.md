 tshark -r /media/hdd/wireshark/11.05.14.pcap -T fields -e http.cookie  -Y http.cookie  > cookies.txt
