# Understanding UDP vs. TCP for Network Programming: Structures, Applications, and Performance Considerations

## Introduction

When exploring online you may think that every website you visit or email you send is just part of the unlimited access that your device has to the internet. However, every digital interaction and byte of data transferred over a network has to abide by a working set of rules. The Transmission Control Protocol/Internet Protocol (TCP/IP) serves as this governance through a suite of communication protocols used to interconnect network devices on the internet [1]. This protocol involves the handling of how data is broken down, addressed, transmitted, routed and received over a network [1]. We will focus on comparing two protocols within the Transport Layer of TCP/IP— Transfer Control Protocol (TCP) and User Datagram Protocol (UDP). This examination will be both qualitative and technical through providing network theory along with insight into the data structures used. (coding guide for network programming in Python.)


## Background on TCP/IP Model

The TCP/IP model is part of every network domain to oversee transmission of data so that it is both efficient and potentially error free. This Internet Protocol Suite was first developed as a way to connect computers within the same network across different countries. The TCP/IP model consists of four “layers” that performs a specific function on the data transmission from start to finish. These layers are divided into Application, Transport, Internet and Network Interface. 

The application layer is responsible for understanding the type of data being used as they are the programs that use network services. Application types include Domain Name Service (DNS), File Transfer Protocol (FTP) and Hypertext Transfer Protocol (HTTP), among many others. The transport layer is responsible for establishing the end-to-end connection between the sender and the receiver while also deciding how to divide the data from the application to send in packets. The internet layer routes this packetized data based on Internet Protocol (the reason IP addresses assigned to each device) and ensures there is a path for the transmission. The network access layer is responsible for the actual transfer of the data through raw binary over the physical communication paths in the network channel [2]

[INSERT PICTURES]

The TCP/IP model involves communication between two parties, the client and the server. The interaction is that a client (often the user machine) is provided a service, like access to a file by a server in the network (another computer). When you type an address to a website (i.e https://www.youtube.com/) the browser first goes to the DNS server where it finds the IP address the website is, then the browser sends HTTP request message to the server to send a copy of the website to your device. After this, if the server approves the message it will send the client back an approval notice and then start to send small packets of data that your browser begins to assemble and display for you [3]. All of this is accomplished over the internet connection established by TCP/IP.


## Methods of TCP and UDP

The Transfer Control Protocol (TCP) and the User Datagram Protocol (UDP) are the two primary protocols that make up the transport layer of the TCP/IP model. Given the type of communication an application will choose one or the other for end-to-end connectivity with the server. 

TCP is a connection oriented protocol that provides reliable transmission of data through a certain set of parameters that are agreed upon by client and the server before this connection is established [5]. 

To establish a connection, there is a three way handshake (Figure _):
  1. Host A must send a synchronize (SYN) message to Host B
  2. Host B responds with an acknowledgment (ACK) message along with a SYN message
  3. Host A responds to the SYN message with its own ACK message

From this point on there is a bidirectional state of communication between the two hosts (client and server). Once this connection is established data can now be exchanged over the network. Regardless of the size of the data, the TCP divides the data into smaller packets and assigns a sequence number so that it can be built back after being received. This sequencing also helps with identifying lost packets to ensure that they are sent again. The size of these packets are decided by the receiving host's TCP window size as a measure of flow control to prevent buffering.[5] 

The process of sending and acknowledging is a continuous process that ensures that both the client and server are on the same page. As illustrated below (Figure  ), the sequence number corresponds with the acknowledgement number based on the size of the receivers (Host B) TCP window. This easily allows the sender and receiver to know which bytes are expected next [5].

[INSERT IMAGE]

There is also a similar meticulous protocol to terminate a TCP connection (Figure ).
 
[INSERT IMAGE]

In contrast, UDP is a connectionless oriented protocol that is much simpler than TCP as it requires no three way handshake, no sequence numbering and no acknowledgments for data received. Essentially UDP packages and sends the data without care about what happens next. While UDP has methods to check whether data is corrupted or not, there is no protocol to solve issues like packets being ordered incorrectly or lost.

## TCP and UDP Structures 

Because there are countless applications that can be used on a given client, both TCP and UDP use port numbers to identify the type of service being requested for a given client or server. A device's IP address in combination with a port number is known as a socket. This allows different network services to operate on the same device. Thus, when a server receives a packet, the port number is what tells the transport layer what application to transfer the packet [5].

Each packet in a TCP or UDP connection is led by a header that contains all information that allows the protocol to govern. The TCP Header includes the source and destination ports, sequence number, acknowledgement number, window size and many more fields (Figure ). Because UDP is more lenient with its protocol, its header is solely the source and destination ports, length of data packet and an error checking variable (Figure ).

Through the stark differences in TCP and UDP connection there is a clear relationship between reliability and speed. By having smaller data headers and less digital oversight, in some cases UDP connections have an advantage over TCP in terms of speed. Whereas, for some applications there is no room for missing packets and reliability is tantamount. Without UDP online gaming would not be as fast, and without TCP everyday messaging would constantly be flawed with missing data. Overall TCP and UDP connections are extremely valuable in the age of communication as it allows for a wide variety of applications that can communicate in different manners.



SOURCES
[1]https://www.techtarget.com/searchnetworking/definition/TCP-IP
[2]https://www.simplilearn.com/tutorials/cyber-security-tutorial/what-is-tcp-ip-mode
[3]https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/How_the_Web_works
[4]https://www.pearsonhighered.com/assets/samplechapter/0/1/3/0/0130322202.pdf
[5]http://routeralley.com/guides/tcp_udp.pdf
