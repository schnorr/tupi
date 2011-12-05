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
#include "DrawView.h"
#include "BasicView.h"

@interface ForceDirectedDelegate : NSObject
{
  BasicView *view;
  NSWindow *window;

  NSSlider *springSlider;
  NSSlider *chargeSlider;
  NSSlider *dampingSlider;

  NSTextField *springLabel;
  NSTextField *chargeLabel;
  NSTextField *dampingLabel;
  
  //for animation
  NSTimer *timer;

  //graph
  Agraph_t *graph;
}
- (void) updateLabels: (id) sender;
- (void) applyForceDirected: (id) sender;
- (void) exportPositions: (id) sender;
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
  NSRect bounds = [view bounds];
  Agnode_t *node = agfstnode (graph);
  while (node){
    ND_coord(node).x = bounds.size.width * drand48();
    ND_coord(node).y = bounds.size.height * drand48();
    node = agnxtnode (graph, node);
  }
  [view setGraph: graph];
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
  double kinetic_energy = [view applyForceDirectedWithSpring: spring
                                                   andCharge: charge
                                                  andDamping: damping];
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
