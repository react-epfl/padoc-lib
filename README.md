# Padoc Library for iOS (v1.0)
Padoc is an Objective-C library runnable on iOS devices whose purpose is to connect smartphones without any external service. It supports a network of any size using multiple hops for message sending. It relies on the Multipeer Connectivity framework for the lower communication primitives between neighbour devices.  
  
By creating a Padoc object, it is possible to send and receive messages to and from any peer in the network.  
The interface is location multicast-based and provides methods for joining and leaving **multicast groups**. When a peer sends a message to a particular group, then only the peers having joint that specific group will receive the message. In addition, it is possible to specify a maximal distance after which peers are not acknowledged anymore.
Indeed, the source peer has no knowledge of which peers will finally receive the message.  
  
This library provides multihop support, meaning that message routing between two points is entirely handled by intermediate peers. Three routing strategies have been implemented so far:
* Broadcast: we use a basic Flooding or the CBS algorithms and the destination group checking is performed by each receiving peer
* Multicast: we use the 6Shots algorithm, which is a real multicast algorithm using location information for route optimization
  
So far, the library works as expected, but still misses some important features:
* No message reliability support
* No congestion control support
  
The major limitation comes from the fact that there is no transport layer still implemented.

## Features

* Direct communication between iOS devices
* Background mode support
* Multihop support for message routing throughout the network
* Support of three routing strategies: broadcast (Flooding and CBS) and multicast (6Shots)
* Diagnostics tools suite


## Limitations

* Device signal range too short (up to 40m)
* No message reliability support
* No transport layer congestion control support


## Dependencies

* iOS >= 7.0, iOS SDK >= 8.0
* MultipeerConnectivity.framework
* CoreLocation.framework
* CoreBluetooth.framework


## Install

In order to use the Padoc library in your project, two options are possible:

* Create your application project
* Include CoreLocation.framework
* Manually copy the content of the ./Padoc folder

or

* Download the library project
* Compile it in order to produce the static library file
* Create your application project
* Include CoreLocation.framework
* Include the static library file

Make sure that WiFi is turned on.

### Initialization

To illustrate the instructions given bellow, a sample app (padoc-sample) showing basic functionality has been included.

The Padoc library uses special objects in order to enter the ad-hoc network  
and perform all operations. 
  
The first step is to initialize the Padoc object (note that the class must implement the  
*MHPadocDelegate* protocol):

```Objective-C
#import "MHPadoc.h"

...

self.padoc = [[MHPadoc alloc] initWithServiceType:@"serviceName"];
self.padoc.delegate = self;
```

In order to support the background mode, some methods must be called  
from the *AppDelegate.m* file. Therefore, we must make sure that the *AppDelegate*  
class contains a reference to our socket and calls certain methods:  

AppDelegate.h
```Objective-C
#import "MHPadoc.h"

...
@interface AppDelegate : UIResponder <UIApplicationDelegate>
...
- (void)setPadocObject:(MHPadoc *)padoc;
```
and AppDelegate.m
```Objective-C
@interface AppDelegate ()
...
@property (nonatomic, strong) MHPadoc *padoc;
...
@end

@implementation AppDelegate


- (void)setPadocObject:(MHPadoc *)padoc
{
    self.padoc = padoc;
}

...
- (void)applicationWillResignActive:(UIApplication *)application {
    ...
    if(self.padoc != nil)
    {
        [self.padoc applicationWillResignActive];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    ...
    if(self.padoc != nil)
    {
        [self.padoc applicationDidBecomeActive];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    ...
    if(self.padoc != nil)
    {
        [self.padoc applicationWillTerminate];
    }
}
...
```

Finally, the class instantiating the object executes:
```Objective-C
AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

[appDelegate setPadocObject:self.padoc];
```

### Basic usage

#### Connection and Disconnection

The Padoc object can be instantiated using the following methods:  

```Objective-C
[[MHPadoc alloc] initWithServiceType:@"service"];

[[MHPadoc alloc] initWithServiceType:@"service"
                  withRoutingProtocol:protocol];

[[MHPadoc alloc] initWithServiceType:@"service"
                          displayName:@"deviceName"
                  withRoutingProtocol:protocol];
```
The currently supported routing protocols are:  
* *MH6ShotsRoutingProtocol*
* *MHFloodingRoutingProtocol*
* *MHCBSRoutingAlgorithm*
  
If unspecified, the default protocol is *MHFloodingRoutingProtocol.*.  
  
In order to disconnect the socket from the network, write:

```Objective-C
[padoc disconnect];
```

If an error occurred during the connection phase, the user is notified  
by the following callback:
```Objective-C
- (void)mhPadoc:(MHPadoc *)mhPadoc failedToConnect:(NSError *)error
{
  ...
}
```


#### Message sending and receiving

In order to send a message, the following command can be called:
```Objective-C
NSError *error;
[padoc multicastMessage:msg
          toDestinations:destinations
                 maxHops:(int)maxHops
                   error:&error];
     
```
Note that *msg* is a NSData object, whereas *destinations* is an array  
containing the target multicast groups. Finally, *maxHops* is an optional  
argument specifying the maximum number of hops after which the message is  
not forwarded anymore.
  
In order to receive messages, the following callback is needed:
```Objective-C
- (void)mhPadoc:(MHPadoc *)mhPadoc
  deliverMessage:(NSData *)data
      fromGroups:(NSArray *)groups
{
  ...
}     
```
Here, the *groups* argument specifies the groups from which originated the message.

#### Group handling
The socket does not address destinations as peer id, but rather as *multicast groups*.  
This means that if a node joined a particular group, it will receive every message from any  
node having sent a message addressed to that group. Therefore, two commands for joining and  
leaving a group are specified:
```Objective-C
[padoc joinGroup:@"groupName" maxHops:(int)maxHops];

[padoc leaveGroup:@"groupName" maxHops:(int)maxHops];
```                

#### Other functions
In order to get the local peer id, one can call the following method: 
```Objective-C
NSString *localPeer = [padoc getOwnPeer];
```  
Note that the peer id is a string that uniquely identifies a node in the network.  
The id is permanent, meaning that if the application is restarted, the same id is  
used again.  
Note however that it is only associated with a particular application. Indeed, if  
the library is used for two different projects, differents ids will be generated  
for the same physical node.  
  
Sometimes, it could be useful to know the number of hops from a particular peer:  
``` Objective-C
int hops = [padoc hopsCountFromPeer:peer];
```  
The function result highly depends on the underlying algorithm. 6Shots provides a reliable  
information, but the Flooding or the CBS algorithms usually give an incorrect result. Indeed,  
only neighbour nodes receive a correct hops count (1). Finally note that the *peer* argument 
is a peer id.

  
  
### Diagnostics tools                 
    
The *MHDiagnostics* class provides options for debugging the network library and check  
where messages transit, or even getting statistical usage results.
              
#### Statistical results and packet tracing

In order to get a complete trace information of any packet that a node receives,  
the following option must be enabled:
```Objective-C
[MHDiagnostics getSingleton].useTraceInfo = YES;
```
Now, the *deliverMessage* callback with a special *traceInfo* argument can be defined.  
It provides an array of peer ids specifying the path that a packet has taken throughout  
the network. It can be called by writing:
```Objective-C
- (void)mhPadoc:(MHPadoc *)mhPadoc
  deliverMessage:(NSData *)data
      fromGroups:(NSArray *)groups
   withTraceInfo:(NSArray*)traceInfo
{
  ...
}     
```

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
- (void)mhPadoc:(MHPadoc *)mhPadoc
neighbourConnected:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName
{
  ...
}

- (void)mhPadoc:(MHPadoc *)mhPadoc
neighbourDisconnected:(NSString *)info
            peer:(NSString *)peer
{
  ...
}
```
#### Network information
In order to have access to a certain number of information about the underlying  
network routing execution, the diagnostics suite provides the following option:
```Objective-C
[MHDiagnostics getSingleton].useNetworkLayerInfoCallbacks = YES;
```

By using this option, the socket gives additional information about which peer in the network  
joined which group:
```Objective-C
- (void)mhPadoc:(MHPadoc *)mhPadoc
     joinedGroup:(NSString *)info
            peer:(NSString *)peer
     displayName:(NSString *)displayName
           group:(NSString *)group
{
  ...
}
```
No information is however given about who left a group.  
  
  
In order to see in real time whether the local peer is currently forwarding packets or not,
and to have access to the packet content, an additional callback is available.
This can be executed by writing:
```Objective-C
- (void)mhPadoc:(MHPadoc *)mhPadoc
   forwardPacket:(NSString *)info
     withMessage:(NSData *)message
      fromSource:(NSString *)peer
{
  ...
}
```
This callback is however valid only for regular packets. Sometimes, it could be useful to follow  
the distribution of some algorithm control packets (like discovery or group joining ones).
This can be enabled by the following code:
```Objective-C
[MHDiagnostics getSingleton].useNetworkLayerControlInfoCallbacks = YES;
```
Now, the *forwardPacket* callback will be executed when control packets are forwarded as well.


### Manual configuration

It is possible to manually configure some parameters important for the library. In order to do so, the  
*MHConfig* class provides a singleton object whose parameters can be changed. In order to call the  
singleton, just write:
```Objective-C
#import "MHConfig.h"
...
[MHConfig getSingleton]. ...
```
The parameter names follow the format *layerParameterName* and are (in parenthesis the default value):

* *linkHeartbeatSendDelay* (2000): number of milliseconds after which a new heartbeat message is sent.
* *linkMaxHeartbeatFails* (5); number of heartbeat message check failures after which a disconnection  
notification is triggered.

* *linkDatagramSendDelay* (250): number of milliseconds after which a new bufferized datagram is sent. This is however only the initial value, The actual value will be adjusted dynamically based on the current traffic.
* *linkMaxDatagramSize* (3000): max size of a datagram. Larger datagrams are cut into chunks.
* *linkBackgroundDatagramSendDelay* (20): number of milliseconds after which a new burrerized datagram (because  
of a background disconnection) is sent.

* *netPacketTTL* (100): standard ttl of a packet (if unspecified by the user).
* *netProcessedPacketsCleaningDelay* (30000): number of milliseconds after which the list containing the processed packets is cleaned.

* *netCBSPacketForwardDelayRange* (100): number of milliseconds defining the delay range of a packet forwarding  
using the CBS algorithm.
* *netCBSPacketForwardDelayBase* (30): number of milliseconds defining the delay base of a packet forwarding  
using the CBS algorithm.

* *net6ShotsControlPacketForwardDelayRange* (50): number of milliseconds defining the delay range of a control  
packet forwarding using the 6Shots algorithm. The final delay is random.
* *net6ShotsControlPacketForwardDelayBase* (20): number of milliseconds defining the delay base of a control  
packet forwarding using the 6Shots algorithm. The final delay is random.
* *net6ShotsPacketForwardDelayRange* (100): number of milliseconds defining the delay range of a packet forwarding  
using the 6Shots algorithm. The final delay is calculated based on the peers location.
* *net6ShotsPacketForwardDelayBase* (30): number of milliseconds defining the delay base of a packet forwarding  
using the 6Shots algorithm. The final delay is calculated based on the peers location.
* *net6ShotsOverlayMaintenanceDelay* (5000): number of milliseconds after which an overlay maintenance operation  
is performed by the node, using the 6Shots algorithm.

* *netDeviceTransmissionRange* (40): transmission range of the device in meters.
* 

# Licence
Copyright (c) 2016 REACT EPFL

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
