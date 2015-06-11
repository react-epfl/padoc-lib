# Multihop Library for IOS (v0.2)
Multihop is an Objective-C library runnable on IOS devices whose purpose is to connect smartphones without  
any external service. It supports a network of any size using multiple hops for message sending.


## Features

* Direct communication between IOS devices
* Background mode support
* Multihop supporting for message routing throughout the network
* Support of 2 routing strategies: unicast (Flooding) and multicast (6Shots)
* Diagnostics tools suite


## Dependencies

* IOS >= 7.0, IOS SDK >= 8.0
* MultipeerConnectivity.framework
* CoreLocation.framework
* CoreBluetooth.framework


## Compilation

In order to compile and use the library, two options are possible:

* Create your application project
* Include CoreLocation.framework
* Manually Copy the content of the ./Multihop folder
* Compile the application as well as the library

or

* Download the library project
* Compile it in order to produce the static library file
* Create your application project
* Include CoreLocation.framework
* Include the static library file


## Utilization

First, make sure that the WIFI is turned on. When using the 6Shots algorithm  
(as described later), make sure that the Bluetooth is turned on.

### Initialization

The Multihop library uses socket objects in order to enter the ad-hoc network  
and perform all operations. The library provides two types of sockets:  
unicast and multicast. During this sub-section, only the unicast socket  
operations are showed as these are very similar for the multicast one.  
  
The first step is to initialize the socket (note that the class must implement the  
*MHUnicastSocketDelegate* or *MHMulticastSocketDelegate* protocols):

```Objective-C
#import "MHUnicastSocket.h"

...

self.uSocket = [[MHUnicastSocket alloc] initWithServiceType:@"serviceName"];
self.uSocket.delegate = self;
```

In order to support the background mode, some socket methods must be called  
from the AppDelegate.m file. Therefore, we must make sure that the AppDelegate  
class contains a reference to our socket and calls certain methods:  

AppDelegate.h
```Objective-C
#import "MHUnicastSocket.h"

...
@interface AppDelegate : UIResponder <UIApplicationDelegate>
...
- (void)setUniSocket:(MHUnicastSocket *)socket;
```
and AppDelegate.m
```Objective-C
@interface AppDelegate ()
...
@property (nonatomic, strong) MHUnicastSocket *uSocket;
...
@end

@implementation AppDelegate


- (void)setUniSocket:(MHUnicastSocket *)socket
{
    self.uSocket = socket;
}

...
- (void)applicationWillResignActive:(UIApplication *)application {
    ...
    if(self.uSocket != nil)
    {
        [self.uSocket applicationWillResignActive];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    ...
    if(self.uSocket != nil)
    {
        [self.uSocket applicationDidBecomeActive];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    ...
    if(self.uSocket != nil)
    {
        [self.uSocket applicationWillTerminate];
    }
}
...
```

Finally, the class instantiating the socket object executes:
```Objective-C
AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

[appDelegate setUniSocket:self.uSocket];
```

### Basic socket usage

#### Connection and Disconnection

The socket can be instantiated using the following methods:  

```Objective-C
[[MHUnicastSocket alloc] initWithServiceType:@"service"];

[[MHUnicastSocket alloc] initWithServiceType:@"service"
                         withRoutingProtocol:protocol];

[[MHUnicastSocket alloc] initWithServiceType:@"service"
                                 displayName:@"device name"
                         withRoutingProtocol:protocol];
```
The currently supported routing protocols are:  
* *MHMulticast6ShotsProtocol*
* *MHUnicastFloodingProtocol*

As these are the only supported and the default ones, there is no practical  
need to specify the protocol during the initialization.  
  
In order to disconnect the socket from the network, write:

```Objective-C
[socket disconnect];
```

If an error occurred during the connection phase, the user is notified  
by the following callback:
```Objective-C
- (void)mhSocket:(MHSocket *)mhSocket failedToConnect:(NSError *)error
{
  ...
}
```


#### Message sending and receiving

In order to send a message, the following command can be called:
```Objective-C
NSError *error;
[socket sendMessage:msg
     toDestinations:destinations
              error:&error];
     
```
Note that *msg* is a NSData object, whereas *destinations* is an array  
containing:  
* For unicast sockets the peer ids of the targets
* For multicast sockets the target groups
  
  
In order to receive messages, the following callback is needed:
```Objective-C
- (void)mhSocket:(MHSocket *)mhSocket
didReceiveMessage:(NSData *)data
        fromPeer:(NSString *)peer
   withTraceInfo:(NSArray *)traceInfo
{
  ...
}     
```
Here, the *peer* argument specifies the peer id that originated the message.  
The *traceInfo* argument will be discussed later.


### Unicast specifications
The unicast socket provides some additional callbacks:
```Objective-C
- (void)mhUnicastSocket:(MHUnicastSocket *)mhUnicastSocket
           isDiscovered:(NSString *)info
                   peer:(NSString *)peer
            displayName:(NSString *)displayName
{
  ...
}

- (void)mhUnicastSocket:(MHUnicastSocket *)mhUnicastSocket
        hasDisconnected:(NSString *)info
                   peer:(NSString *)peer
{
  ...
}
```
The *isDiscovered* callback is called whenever a new peer enters the network.  
It is basically a notification mechanism providing to a node the totality of  
the network peers.  
On the other hand, the *hasDisconnected* callback is only called when neighbour  
peers disconnect.


### Multicast specifications

The multicast socket does not address destinations as peer id, but rather as  
*multicast groups*. This means that if a node joined a particular group, it will  
receive every message from any node addressed to that group. Therefore, two commands  
for joining and leaving a group are specific to the multicast socket:
```Objective-C
[socket joinGroup:@"groupName"];

[socket leaveGroup:@"groupName"];
```                

#### Other functions
In order to get the local peer id, one can call the following method: 
```Objective-C
NSString *localPeer = [socket getOwnPeer];
```  
Note that the peer id is a string that uniquely identifies a node in the network.  
The id is permanent, meaning that if the application is restarted, the same id is  
used again.  
Note however that it is only associated with a particular application. Indeed, if  
the library is used for two different projects, differents ids will be generated  
for the same physical node.  
  
Sometimes, it could be useful to know the number of hops from a particular peer:  
``` Objective-C
int hops = [socket hopsCountFromPeer:peer];
```  
The result highly depends on the underlying algorithm. 6Shots provides a reliable  
information, but the Flooding algorithm usually gives an incorrect result. Indeed,  
only neighbour nodes receive a correct hops count (1).

  
### Diagnostics tools                 
    
The *MHDiagnostics* class provides options for debugging the network library and check  
where messages transit, or even getting statistical usage results.
              
#### Statistical results and packet tracing

In order to get a complete trace information of any packet that a node receives, it  
must enable the following option:
```Objective-C
[MHDiagnostics getSingleton].useTraceInfo = YES;
```
Now, the *traceInfo* argument of the *didReceiveMessage* callback provides an array  
of peer ids specifying the path that a packet has taken throughout the network.
  
In order to check the algorithm performance, the **retransmission ratio** can be useful.  
It provides a quantitative measure of the number of retransmitted packets. In order to  
enable it, just write:
```Objective-C
[MHDiagnostics getSingleton].useRetransmissionInfo = YES;
...
// After the node has disconnected
double ratio = [[MHDiagnostics getSingleton] getRetramsissionRatio];
```
This ratio corresponds to the number of received packets divided by the number of forwarded  
ones. Indeed, the lower the ratio, the better the algorithm, provided that the **distribution  
ratio** is still high.

#### Neighbour information
In order to know what are the directly connected peers (neighbourhood), use:
```Objective-C
[MHDiagnostics getSingleton].useNeighbourInfo = YES;
```
Now, the following callbacks are available:
```Objective-C
- (void)mhSocket:(MHSocket *)mhSocket
neighbourConnected:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName
{
  ...
}

- (void)mhSocket:(MHSocket *)mhSocket
neighbourDisconnected:(NSString *)info
            peer:(NSString *)peer
{
  ...
}
```
#### Network information
In order to see in real time whether the local peer is currently forwarding packets or not,  
and to have access to the packet content, additional callbacks are available. These can be  
enabled by calling:
```Objective-C
[MHDiagnostics getSingleton].useNetworkLayerInfoCallbacks = YES;

...

// The callback is
- (void)mhSocket:(MHSocket *)mhSocket
   forwardPacket:(NSString *)info
     withMessage:(NSData *)message
      fromSource:(NSString *)peer
{
  ...
}
```
This callback is however valid only for regular packets. Sometimes, it could be useful to follow  
the distribution of some algorithm control packets (like discovery ones). This can be enabled  
by the following code:
```Objective-C
[MHDiagnostics getSingleton].useNetworkLayerControlInfoCallbacks = YES;
```
  
  
Finally, the multicast socket gives additional information about which peer joined which group:  
```Objective-C
- (void)mhMulticastSocket:(MHMulticastSocket *)mhMulticastSocket
              joinedGroup:(NSString *)info
                     peer:(NSString *)peer
                    group:(NSString *)group
{
  ...
}
```
No information is however given about who leaved a group.

