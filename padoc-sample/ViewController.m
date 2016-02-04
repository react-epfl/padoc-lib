//
//  ViewController.m
//  padoc-lib
//
//  Created by Gabriel on 03/02/16.
//  Copyright © 2016 REACT. All rights reserved.
//

#import "ViewController.h"

//  import the Paddoc interface as well as the App delegate.
#import "MHPaddoc.h"
#import "AppDelegate.h"
#import "MHPeer.h"
#import "MHMultipeerWrapper.h"

//  This will be the global group to join
#define GLOBAL @"global"

//  Make sure the class is implementing the MHPaddocDelegate protocol
@interface ViewController () <MHPaddocDelegate>

//  Declare the actual paddoc object
@property (strong, nonatomic) MHPaddoc *paddoc;
@property (nonatomic) BOOL connectionIsOK;
@property (nonatomic) NSString *peer_id;
@property (nonatomic, strong) NSMutableArray *connectedPeers;
@property (strong, nonatomic) MHPeer *peer;


//  Declare some sample fields
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UITextField *inputField;
@property (nonatomic, retain) IBOutlet UITableView *peersTable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  Enable neighbouring information
    [MHDiagnostics getSingleton].useNeighbourInfo = YES;
    
    // Initialize peers array
    self.connectedPeers = [[NSMutableArray alloc] init];
    
    if (self.paddoc == nil) {
        
        //Set up the paddoc(socket) and the groups
        self.paddoc = [[MHPaddoc alloc] initWithServiceType:@"demoService"];
        self.paddoc.delegate = self;
        
        //Set the peer ID
        self.peer_id = [self.paddoc getOwnPeer];
        
        //For background mode
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate setPaddocObject:self.paddoc];
        
        // Join the groups
        [self.paddoc joinGroup:GLOBAL];
        [self.paddoc joinGroup:self.peer_id];
    }
    
    self.connectionIsOK = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//  "SEND" button is pressed
-(IBAction)SendButton {
    
    NSString *message = self.inputField.text;
    
    if ([message length] == 0) {
        message = @"Hello World";
    }
    
    [self sendMessage:message];
    
    self.messageLabel.text = message;
}

// Send message
- (void)sendMessage:(NSString *)message{
    NSData *msgData = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    [self.paddoc multicastMessage:msgData
                   toDestinations:[[NSArray alloc] initWithObjects:GLOBAL, nil]
                            error:&error];
}

//Implement the callback method failedToConnect in case of error during connection
- (void)mhPaddoc:(MHPaddoc *)mhPaddoc failedToConnect:(NSError *)error
{
    self.connectionIsOK = NO;
}

//  Implement the callback method deliverMessage in case of receiving a message
- (void)mhPaddoc:(MHPaddoc *)mhPaddoc
  deliverMessage:(NSData *)data
      fromGroups:(NSArray *)groups
{
    NSString* msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.messageLabel.text = msg;
}

- (void)mhPaddoc:(MHPaddoc *)mhPaddoc neighbourConnected:(NSString *)info peer:(NSString *)peer displayName:(NSString *)displayName
{
    //NSLog(@"NEIGHBOUR CONNECTED");
    [self.connectedPeers addObject:peer];
    [self.peersTable reloadData];
}

- (void)mhPaddoc:(MHPaddoc *)mhPaddoc
neighbourDisconnected:(NSString *)info
            peer:(NSString *)peer
{
    //NSLog(@"NEIGHBOUR DISCONNECTED");
    [self.connectedPeers removeObject:peer];
    [self.peersTable reloadData];
}


//  Only available when using 6Shot protocol
-(void)mhPaddoc:(MHPaddoc *)mhPaddoc joinedGroup:(NSString *)info peer:(NSString *)peer displayName:(NSString *)displayName group:(NSString *)group
{
    //NSLog(@"PEER CONNECTED");
}

//  Implement nomberOfRowsInSection
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.connectedPeers count];
}

// Implement cellForRowAtIndexPath
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *peerTableIdentifier = @"peerTable";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:peerTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:peerTableIdentifier];
    }
    
    cell.textLabel.text = [self.connectedPeers objectAtIndex:indexPath.row];
    return cell;
}

@end
