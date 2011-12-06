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

@interface FDTree : NSObject
{
  NSRect mycell;
  FDTree *parent;
  NSMutableArray *children; //of FDTree objects
  NSPoint particle;
  NSPoint pseudoParticle;
}
- (id) initWithCell: (NSRect)c
             parent: (FDTree*)p;
- (void) addParticle: (NSPoint)p;
- (NSRect) cell;
- (void) printWithDepth: (int)level;
- (BOOL) isEmpty;
- (void) clean;
@end

@implementation FDTree
- (id) initWithCell: (NSRect)c
             parent: (FDTree*)p
{
  self = [super init];
  mycell = c;
  parent = p;
  children = nil;
  particle = NSZeroPoint;
  pseudoParticle = NSZeroPoint;
  return self;
}

- (void) dealloc
{
  [children release];
  [super dealloc];
}

- (void) splitCell
{
  NSPoint c = NSMakePoint(NSMidX(mycell), NSMidY(mycell));
  NSRect bottomLeft = NSMakeRect(mycell.origin.x, mycell.origin.y,
                                 mycell.size.width/2,
                                 mycell.size.height/2);
  FDTree *c1 = [[FDTree alloc] initWithCell: bottomLeft
                                     parent: self];


  NSRect bottomRight = NSMakeRect(c.x, mycell.origin.y, 
                                  mycell.size.width/2,
                                  mycell.size.height/2);
  FDTree *c2 = [[FDTree alloc] initWithCell: bottomRight
                                     parent: self];


  NSRect topLeft = NSMakeRect(mycell.origin.x,c.y,
                              mycell.size.width/2,
                              mycell.size.height/2);
  FDTree *c3 = [[FDTree alloc] initWithCell: topLeft
                                     parent: self];


  NSRect topRight = NSMakeRect(c.x, c.y,
                               mycell.size.width/2,
                               mycell.size.height/2);
  FDTree *c4 = [[FDTree alloc] initWithCell: topRight
                                     parent: self];
  children = [[NSMutableArray alloc] initWithObjects: c1, c2, c3, c4, nil];
}

- (void) addParticle: (NSPoint)p
{
  NSLog (@"%@ add %@", self, NSStringFromPoint(p));
  //three situations
  //0 - zero particle, zero children
  //1 - one particle, zero children
  //2 - zero particle, four children

  if (NSEqualPoints(particle, NSZeroPoint) && children == nil){

    NSLog (@"Case #0");
    particle = p;


  }else if(!NSEqualPoints(particle, NSZeroPoint) && children == nil){


    NSLog (@"Case #1.1");
    [self splitCell];
    //add current particle to children
    NSEnumerator *e = [children objectEnumerator];
    FDTree *child;
    while ((child = [e nextObject])){
      if (NSPointInRect(particle, [child cell])){
        [child addParticle: particle];
        particle = NSZeroPoint;
        break;
      }
    }

    NSLog (@"Case #1.2");
    //add new particle to children
    e = [children objectEnumerator];
    while ((child = [e nextObject])){
      if (NSPointInRect(p, [child cell])){
        [child addParticle: p];
        break;
      }
    }


  }else if(NSEqualPoints(particle, NSZeroPoint) && children != nil){


    NSLog (@"Case #2");
    //add new particle
    NSEnumerator *e = [children objectEnumerator];
    FDTree *child;
    while ((child = [e nextObject])){
      if (NSPointInRect(p, [child cell])){
        [child addParticle: p];
        break;
      }
    }


  }else{
    NSLog (@"unknow state");
    exit(1);
  }
  return;
}

- (NSRect) cell
{
  return mycell;
}

- (void) printWithDepth: (int)level
{
  if (NSEqualPoints(particle, NSZeroPoint)){
    NSLog(@"|%*.*s<%p> c=%lu", level, level, "", self, [children count]);
  }else{
    NSLog(@"|%*.*s<%p> c=%lu p=%@", level, level, "", self, [children count], NSStringFromPoint(particle));
  }
  NSEnumerator *e = [children objectEnumerator];
  FDTree *child;
  while ((child = [e nextObject])){
    [child printWithDepth: level+1];
  }
}

- (BOOL) isEmpty
{
  // NSLog (@"isEmpty? <%p> c=%lu, particle=%@", self, [children count], 
  //        NSStringFromPoint(particle));
  return ([children count] == 0 &&
          NSEqualPoints(particle, NSZeroPoint));
}

- (void) clean
{
  NSMutableSet *removal = [NSMutableSet set];
  NSEnumerator *e = [children objectEnumerator];
  FDTree *child;
  while ((child = [e nextObject])){
    if ([child isEmpty]){
      [removal addObject: child];
    }
  }
  e = [removal objectEnumerator];
  while ((child = [e nextObject])){
    [children removeObject: child];
  }

  //iterate
  e = [children objectEnumerator];
  while ((child = [e nextObject])){
    [child clean];
  }
}
@end

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

  //graph
  Agraph_t *graph;
}
- (void) updateLabels: (id) sender;
- (void) resetPositions: (id) sender;
- (void) applyForceDirected: (id) sender;
- (void) exportPositions: (id) sender;
- (void) forceDirectedAlgorithmV1: (id) sender;
- (void) forceDirectedAlgorithmV2: (id) sender;
@end

@implementation ForceDirectedDelegate : NSObject 
- (void) applicationDidFinishLaunching: (NSNotification *)not;
{
  [NSBundle loadGSMarkupNamed: @"ForceDirected"  owner: self];
  [window makeKeyAndOrderFront: self];
  [window setDelegate: self];
  [self updateLabels: self];

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
  graph = agread (file);
  if (!graph){
    NSLog (@"Could not read a graph from file %@ (agread)", dot);
    [[NSApplication sharedApplication] terminate:self];
  }

  //set random positions of all nodes based on view bounds
  [self resetPositions: self];


  //launch thread
  lock = [[NSConditionLock alloc] initWithCondition: 0];
  // NSThread *thread = [[NSThread alloc] initWithTarget: self
  //                                            selector:
  //                                        @selector(forceDirectedAlgorithmV1:)
  //                                              object: nil];
  //[thread start];

  [self forceDirectedAlgorithmV2: self];

  [view setGraph: graph withConditionLock: lock];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
  agclose(graph);
}

- (void) updateLabels: (id) sender
{
  [springLabel setFloatValue: [springSlider floatValue]];
  [chargeLabel setFloatValue: [chargeSlider floatValue]];
  [dampingLabel setFloatValue: [dampingSlider floatValue]];
}

- (void) applyForceDirected: (id) sender
{
  double spring = [springSlider floatValue];
  double charge = [chargeSlider floatValue];
  double damping = [dampingSlider floatValue];
  double kinetic_energy = 0;// [view applyForceDirectedWithSpring: spring
                            //                        andCharge: charge
                            //                       andDamping: damping];
  [timer invalidate];
  if (kinetic_energy < 0.001){
    timer = [NSTimer scheduledTimerWithTimeInterval: 2
                                    target: self
                                  selector: @selector(applyForceDirected:)
                                  userInfo: nil
                                   repeats: YES];
  }else{
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.05
                                    target: self
                                  selector: @selector(applyForceDirected:)
                                  userInfo: nil
                                   repeats: YES];
  }
}

- (void) exportPositions: (id) sender
{
  [view exportPositions];
}

- (void) resetPositions: (id) sender
{
  srand48(time(NULL));
  NSRect bounds = [view bounds];
  Agnode_t *node = agfstnode (graph);
  while (node){
    ND_coord(node).x = bounds.size.width * drand48();
    ND_coord(node).y = bounds.size.height * drand48();
    node = agnxtnode (graph, node);
  }
  [self forceDirectedAlgorithmV2: sender];
  [view setNeedsDisplay: YES];
}

- (void) forceDirectedAlgorithmV2: (id) sender
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  Agnode_t *node = agfstnode(graph);
  NSRect bounds = NSZeroRect;
  while(node){
    NSRect np = NSMakeRect (ND_coord(node).x, ND_coord(node).y, 1, 1);
    bounds = NSUnionRect(bounds, np);
    node = agnxtnode(graph, node);
  }

  FDTree *t = [[FDTree alloc] initWithCell: bounds parent: nil];
  node = agfstnode(graph);
  while(node){
    NSPoint np = NSMakePoint (ND_coord(node).x, ND_coord(node).y);
    NSLog (@"adding particle %@", NSStringFromPoint(np));
    [t addParticle: np];
    node = agnxtnode(graph,node);
  }

  //print tree
  NSLog (@"print the tree");
  [t clean];
  [t printWithDepth: 0];

  [pool release];
}

- (void) forceDirectedAlgorithmV1: (id) sender
{
  if (!graph) return;

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  Agnode_t *n1, *n2;
  NSDate *lastViewUpdate = [NSDate distantPast];

  // set up initial node velocities to (0,0)
  n1 = agfstnode (graph);
  while (n1){
    agsafeset (n1, "dx", "0", "0");
    agsafeset (n1, "dy", "0", "0");
    n1 = agnxtnode (graph, n1);
  }

  while (![[NSThread currentThread] isCancelled]){

    float spring = [springSlider floatValue];
    float charge = [chargeSlider floatValue];
    float damping = [dampingSlider floatValue];

    // running sum of total kinetic energy over all particles
    NSPoint total_kinetic_energy = NSMakePoint (0,0);
    total_kinetic_energy = NSMakePoint(0,0);

    [lock lock];

    n1 = agfstnode (graph);
    while (n1){
      //NSString *name = [NSString stringWithFormat: @"%s", n1->name];
      // running sum of total force on this particular node
      NSPoint force = NSMakePoint (0, 0);

      n2 = agfstnode (graph);
      while (n2){
        //distance between particles
        NSPoint n1p = NSMakePoint (ND_coord(n1).x, ND_coord(n1).y);
        NSPoint n2p = NSMakePoint (ND_coord(n2).x, ND_coord(n2).y);
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
 
          if (agfindedge (graph, n1, n2)){
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
        n2 = agnxtnode (graph, n2);
      }

      NSPoint velocity = NSMakePoint (atof(agget (n1, "dx")),
                                      atof(agget (n1, "dy")));
      velocity = NSAddPoints (velocity, force);
      velocity = LMSMultiplyPoint (velocity, damping);
 
      ND_coord(n1).x = ND_coord(n1).x + velocity.x;
      ND_coord(n1).y = ND_coord(n1).y + velocity.y;
 
      //save velocity?

      total_kinetic_energy = NSAddPoints (total_kinetic_energy, velocity); 

      n1 = agnxtnode (graph, n1);
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
