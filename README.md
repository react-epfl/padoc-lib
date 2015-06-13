# Multihop Library for IOS (v0.3)
Multihop is an Objective-C library runnable on IOS devices whose purpose is to connect smartphones without  
any external service. It supports a network of any size using multiple hops for message sending. It relies on the Multipeer Connectivity framework for the lower communication primitives between neighbour devices.  
  
By creating a socket object, it is possible to send and receive messages to and from any peer in the network.  
The interface is multicast-based and provides methods for joining and leaving **multicast groups**. When a peer sends a message to a particular group, then only the peers having joint the specific group will receive the message. Indeed, the source peer has no knowledge of which peers will finally receive the message.  
  
This library provides multihop support, meaning that message routing between two points is entirely handled by intermediate peers. Two routing strategies have been implemented so far:
* Broadcast: we use a basic Flooding algorithm and the destination group checking is performed by each receiving peer
* Multicast: we use the 6Shots algorithm, which is a real multicast algorithm using location information for routing optimization
  
So far, the library works as expected, but still misses some important features:
* Device signal range too short (up to 40m)
* No message reliability support
* No congestion control support
The major limitations come from the fact that there is still no transport layer.

## Features

* Direct communication between IOS devices
* Background mode support
* Multihop supporting for message routing throughout the network
* Support of 2 routing strategies: broadcast (Flooding) and multicast (6Shots)
* Diagnostics tools suite


## Limitations

* No message reliability support
* No congestion control support


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

First, make sure that WIFI and Bluetooth are turned on.

### Initialization

The Multihop library uses socket objects in order to enter the ad-hoc network  
and perform all operations. 
  
The first step is to initialize the socket (note that the class must implement the  
*MHSocketDelegate* protocol):

```Objective-C
#import "MHSocket.h"

...

self.socket = [[MHSocket alloc] initWithServiceType:@"serviceName"];
self.socket.delegate = self;
```

In order to support the background mode, some socket methods must be called  
from the *AppDelegate.m* file. Therefore, we must make sure that the *AppDelegate*  
class contains a reference to our socket and calls certain methods:  

AppDelegate.h
```Objective-C
#import "MHSocket.h"

...
@interface AppDelegate : UIResponder <UIApplicationDelegate>
...
- (void)setNetworkSocket:(MHSocket *)socket;
```
and AppDelegate.m
```Objective-C
@interface AppDelegate ()
...
@property (nonatomic, strong) MHSocket *socket;
...
@end

@implementation AppDelegate


- (void)setNetworkSocket:(MHSocket *)socket
{
    self.socket = socket;
}

...
- (void)applicationWillResignActive:(UIApplication *)application {
    ...
    if(self.socket != nil)
    {
        [self.socket applicationWillResignActive];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    ...
    if(self.socket != nil)
    {
        [self.socket applicationDidBecomeActive];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    ...
    if(self.socket != nil)
    {
        [self.socket applicationWillTerminate];
    }
}
...
```

Finally, the class instantiating the socket object executes:
```Objective-C
AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

[appDelegate setnetworkSocket:self.socket];
```

### Basic socket usage

#### Connection and Disconnection

The socket can be instantiated using the following methods:  

```Objective-C
[[MHSocket alloc] initWithServiceType:@"service"];

[[MHSocket alloc] initWithServiceType:@"service"
                  withRoutingProtocol:protocol];

[[MHSocket alloc] initWithServiceType:@"service"
                          displayName:@"device name"
                  withRoutingProtocol:protocol];
```
The currently supported routing protocols are:  
* *MH6ShotsRoutingProtocol*
* *MHFloodingRoutingProtocol*
If unspecified, the default protocol is *MHFloodingRoutingProtocol.*.  
  
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
containing the target multicast groups.
  
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

#### Group handling
The socket does not address destinations as peer id, but rather as *multicast groups*.  
This means that if a node joined a particular group, it will receive every message from any  
node having sent a message addressed to that group. Therefore, two commands for joining and  
leaving a group are specified:
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
In order to have access to a certain number of information about the underlying  
routing execution, the diagnostics suite provides the following option:
```Objective-C
[MHDiagnostics getSingleton].useNetworkLayerInfoCallbacks = YES;
```

By using this option, the socket gives additional information about which peer in the network  
joined which group:
```Objective-C
- (void)mhSocket:(MHSocket *)mhSocket
     joinedGroup:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName
           group:(NSString *)group
{
  ...
}
```
No information is however given about who leaved a group.  
  
  
This is however not the only information.  
In order to see in real time whether the local peer is currently forwarding packets or not,  
and to have access to the packet content, an additional callback is available. This can be  
execute by writing:
```Objective-C
- (void)mhSocket:(MHSocket *)mhSocket
   forwardPacket:(NSString *)info
     withMessage:(NSData *)message
      fromSource:(NSString *)peer
{
  ...
}
```
This callback is however valid only for regular packets. Sometimes, it could be useful to follow  
the distribution of some algorithm control packets (like discovery or group joining ones). This can  
be enabledby the following code:
```Objective-C
[MHDiagnostics getSingleton].useNetworkLayerControlInfoCallbacks = YES;
```
Now, the *forwardPacket* callback will be executed when control packets are forwarded as well.
