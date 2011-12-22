/*
    This file is part of ForceDirected

    ForceDirected is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    ForceDirected is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with ForceDirected.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>
#include <graphviz/types.h>
#include <graphviz/graph.h>
#include <stdio.h>
#include <stdlib.h>
#include "ForceDirectedView.h"
#include "NSPointFunctions.h"
#include "FDTree.h"
#include "GraphNode.h"

@interface ForceDirectedDelegate : NSObject
{
  ForceDirectedView *view;
  NSWindow *window;

  NSSlider *springSlider;
  NSSlider *chargeSlider;
  NSSlider *dampingSlider;

  NSTextField *springLabel;
  NSTextField *chargeLabel;
  NSTextField *dampingLabel;
  
  //for animation
  NSTimer *timer;

  //for lock
  NSConditionLock *lock;

  //the nodes of the graph (instances of GraphNode)
  NSMutableDictionary *graph;

  FDTree *tree;
}
- (void) updateLabels: (id) sender;
- (void) resetPositions: (id) sender;
- (void) exportPositions: (id) sender;
- (void) forceDirectedAlgorithmV1: (id) sender;
- (void) forceDirectedAlgorithmV2: (id) sender;
@end

@implementation ForceDirectedDelegate : NSObject 
- (void) applicationWillFinishLaunching: (NSNotification *)not
{
  //get the dot file as argument
  NSArray *args = [[NSProcessInfo processInfo] arguments];
  if ([args count] < 2){
    NSLog (@"Usage: %@ <graphviz_dot_file>", [args objectAtIndex: 0]);
    [[NSApplication sharedApplication] terminate:self];
  }
  NSString *dot = [args objectAtIndex: 1];
  FILE *file = fopen ([dot cString], "r");
  if (!file){
    NSLog (@"Could not open file %@", dot);
    [[NSApplication sharedApplication] terminate:self];
  }
  Agraph_t *g = agread (file);
  if (!g){
    NSLog (@"Could not read a graph from file %@ (agread)", dot);
    [[NSApplication sharedApplication] terminate:self];
  }

  //reading nodes/edges
  graph = [[NSMutableDictionary alloc] init];
  Agnode_t *n1 = agfstnode (g);
  while (n1){
    NSString *name1 = [NSString stringWithFormat: @"%s", n1->name];
    GraphNode *node1 = [graph objectForKey: name1];
    if (!node1){
      node1 = [[GraphNode alloc] init];
      [node1 setName: name1];
      [graph setObject: node1 forKey: name1];
      [node1 release];
    }

    for (Agnode_t *n2 = agfstnode (g); n2; n2 = agnxtnode (g, n2)){
      if (agfindedge (g, n1, n2)){
        //n1 and n2 are connected
        NSString *name2 = [NSString stringWithFormat: @"%s", n2->name];
        GraphNode *node2 = [graph objectForKey: name2];
        if (!node2){
          node2 = [[GraphNode alloc] init];
          [node2 setName: name2];
          [graph setObject: node2 forKey: name2];
          [node2 release];
        }
        [node1 addConnectedNode: node2];
        [node2 addConnectedNode: node1];
      }
    }
    n1 = agnxtnode (g, n1);
  }
  agclose(g);

  NSEnumerator *en = [graph objectEnumerator];
  GraphNode *n;
  while ((n = [en nextObject])){
    NSLog (@"%@ %@", n, [n connectedNodes]);
  }
}

- (void) applicationDidFinishLaunching: (NSNotification *)not;
{
  [NSBundle loadGSMarkupNamed: @"ForceDirected"  owner: self];
  [window makeKeyAndOrderFront: self];
  [window setDelegate: self];
  [self updateLabels: self];

  //set random positions of all nodes based on view bounds
  [self resetPositions: self];

  //launch thread
  lock = [[NSConditionLock alloc] initWithCondition: 0];
  NSThread *thread = [[NSThread alloc] initWithTarget: self
                                             selector:
                                         @selector(forceDirectedAlgorithmV1:)
                                               object: nil];
  [thread start];

  // NSThread *thread = [[NSThread alloc] initWithTarget: self
  //                                            selector:
  //                                        @selector(forceDirectedAlgorithmV2:)
  //                                              object: nil];
  // [thread start];

  [view setGraph: graph withConditionLock: lock];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
  NSLog (@"leaving...");
  [graph release];
}

- (void) updateLabels: (id) sender
{
  [springLabel setFloatValue: [springSlider floatValue]];
  [chargeLabel setFloatValue: [chargeSlider floatValue]];
  [dampingLabel setFloatValue: [dampingSlider floatValue]];
}

- (void) exportPositions: (id) sender
{
  [view exportPositions];
}

- (void) resetPositions: (id) sender
{
  srand48(0);

  // set up initial node velocities to (0,0)
  // Agnode_t *n1 = agfstnode (graph);
  // while (n1){
  //   agsafeset (n1, "dx", "0", "0");
  //   agsafeset (n1, "dy", "0", "0");
  //   n1 = agnxtnode (graph, n1);
  // }

  NSRect bounds = [view bounds];
  NSEnumerator *en = [graph objectEnumerator];
  GraphNode *node;
  while ((node = [en nextObject])){
    NSPoint newPosition = NSMakePoint (bounds.size.width * drand48(),
                                       bounds.size.height * drand48());
    [node setPosition: newPosition];
    NSLog (@"%@ %@", node, NSStringFromPoint ([node position]));
  }
  [view setNeedsDisplay: YES];
}

- (void) forceDirectedAlgorithmV2: (id) sender
{
  if (!graph) return;
  NSDate *lastViewUpdate = [NSDate distantPast];

  while (![[NSThread currentThread] isCancelled]){
    [NSThread sleepForTimeInterval: .1];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [lock lock];

    //define bounds for barnes-hut root cell
    NSRect rootCellbounds = NSZeroRect;
    NSEnumerator *en = [graph objectEnumerator];
    GraphNode *node;
    while ((node = [en nextObject])){
      NSPoint p = [node position];
      NSRect np = NSMakeRect (p.x, p.y, 1, 1);
      rootCellbounds = NSUnionRect(rootCellbounds, np);
    }

    //create/clean-up a new barnes-hut tree by adding particles one at a time
    if (tree){
      [tree release];
    }
    tree = [[FDTree alloc] initWithCell: rootCellbounds parent: nil];
    [view setTree: tree];
    FDTree *t = tree;
    en = [graph objectEnumerator];
    while ((node = [en nextObject])){
      [t addParticle: [node position]];
    }
    [t clean];    //tree clean-up, remove empty cells

    // calculate forces
    float spring = [springSlider floatValue];
    float charge = [chargeSlider floatValue];
    float damping = [dampingSlider floatValue];

T1
    en = [graph objectEnumerator];
    while ((node = [en nextObject])){
      NSPoint force = [t coulombRepulsionOfParticle:[node position]
                                             charge:charge
                                           accuracy:1];

      //spring
      NSEnumerator *connectedEn = [[node connectedNodes] objectEnumerator];
      GraphNode *connectedNode;
      while ((connectedNode = [connectedEn nextObject])){
        NSPoint n1p = [node position];
        NSPoint n2p = [connectedNode position];
        NSPoint dif = NSSubtractPoints (n1p, n2p);
        double distance = LMSDistanceBetweenPoints (n1p, n2p);

        //hooke_attraction (-k * x)
        double hooke_attraction = 1 - (fabs (distance - spring) / spring);
        force = NSAddPoints (force,
                             LMSMultiplyPoint (LMSNormalizePoint(dif),
                                               hooke_attraction));
      }

      NSPoint velocity = NSZeroPoint;
      velocity = NSAddPoints (velocity, force);
      velocity = LMSMultiplyPoint (velocity, damping);
 
      [node setPosition: NSAddPoints([node position], velocity)];
    }
T2
  // exit(1);
   [lock unlock];

   if(1){
     //update view?
     NSDate *now = [NSDate dateWithTimeIntervalSinceNow: 0];
     double difTime = [now timeIntervalSinceDate: lastViewUpdate];
     if (difTime > 0.01){
       [lastViewUpdate release];
       lastViewUpdate = now;
       [view setNeedsDisplay: YES];
     }
     [lastViewUpdate retain];
   }

    [pool release];
  }
}

- (void) forceDirectedAlgorithmV1: (id) sender
{
  if (!graph) return;

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSDate *lastViewUpdate = [NSDate distantPast];

  while (![[NSThread currentThread] isCancelled]){
    [NSThread sleepForTimeInterval: .1];

    float spring = [springSlider floatValue];
    float charge = [chargeSlider floatValue];
    float damping = [dampingSlider floatValue];

    // running sum of total kinetic energy over all particles

    [lock lock];
    NSEnumerator *en1 = [graph objectEnumerator];
    GraphNode *n1;
    while ((n1 = [en1 nextObject])){

      // running sum of total force on this particular node
      NSPoint force = NSMakePoint (0, 0);

      NSEnumerator *en2 = [graph objectEnumerator];
      GraphNode *n2;
      while ((n2 = [en2 nextObject])){
        //distance between particles
        NSPoint n1p = [n1 position];
        NSPoint n2p = [n2 position];
        NSPoint dif = NSSubtractPoints (n1p, n2p);
        double distance = LMSDistanceBetweenPoints (n1p, n2p);

        if (n1 != n2){
          //calculate coulomb repulsion and hooke attraction
          double coulomb_repulsion = 0;
          double hooke_attraction = 0; 

          //coulomb_repulsion (k_e * (q1 * q2 / r*r))
          double coulomb_constant = 1;
          double r = distance;
          double q1 = charge;
          double q2 = charge;
          coulomb_repulsion = coulomb_constant * (q1*q2)/(r*r);
 
          if ([n1 isConnectedTo: n2]){
            //hooke_attraction (-k * x)
            hooke_attraction = 1 - (fabs (distance - spring) / spring);
          }
          force = NSAddPoints (force,
                               LMSMultiplyPoint (LMSNormalizePoint(dif),
                                                 coulomb_repulsion));
          force = NSAddPoints (force,
                               LMSMultiplyPoint (LMSNormalizePoint(dif),
                                                 hooke_attraction));
        }
      }

      NSPoint velocity = NSZeroPoint;
      velocity = NSAddPoints (velocity, force);
      velocity = LMSMultiplyPoint (velocity, damping);
      [n1 setPosition: NSAddPoints([n1 position], velocity)];
    }
    [lock unlock];

    //update view?
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow: 0];
    double difTime = [now timeIntervalSinceDate: lastViewUpdate];
    if (difTime > 0.01){
      [lastViewUpdate release];
      lastViewUpdate = now;
      [view setNeedsDisplay: YES];
    }
    [lastViewUpdate retain];
  }
  [pool release];
}

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}
@end

int main (int argc, const char **argv)
{
  aginit();
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSApplication *app = [NSApplication sharedApplication];
  ForceDirectedDelegate *delegate = [ForceDirectedDelegate new];
  [app setDelegate: delegate];

  RELEASE(pool);
  return NSApplicationMain (argc, argv);
}
