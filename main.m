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
#include <graphviz/gvc.h>
#include "DrawView.h"

@interface ForceDirectedDelegate : NSObject
{
  id view;

  int argc;
  char **argv;

  GVC_t *gvc;
  graph_t *graph;

  NSSlider *springSlider;
  NSSlider *chargeSlider;
  NSSlider *dampingSlider;

  NSTextField *springLabel;
  NSTextField *chargeLabel;
  NSTextField *dampingLabel;
  
  //for animation
  NSTimer *timer;
}
- (void) initWithArgc: (int) c argv: (char**) v;
- (void) applicationDidFinishLaunching: (NSNotification *)not;
- (void) updateLabels: (id) sender;
- (void) applyForceDirected: (id) sender;
- (void) exportPositions: (id) sender;
@end

@implementation ForceDirectedDelegate : NSObject 
- (void) initWithArgc: (int) c argv: (char**) v
{
  argc = c;
  argv = v; 
  timer = nil;
}

- (void) applicationDidFinishLaunching: (NSNotification *)not;
{
  [NSBundle loadGSMarkupNamed: @"ForceDirected"  owner: self];

  gvc = gvContext();
  gvParseArgs (gvc, argc, (char**)argv);
  graph = gvNextInputGraph(gvc);
//  gvLayout (gvc, graph, "neato");
  [view setGVC: gvc];
  [view setGraph: graph];
  [view reset: self];
  [self updateLabels: self];
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
@end

int main (int argc, const char **argv){
  if (argc == 1){
    NSLog (@"%s <file.dot>", argv[0]);
    return 0;
  }

  //appkit init
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSApplication *app = [NSApplication sharedApplication];
  ForceDirectedDelegate *delegate = [ForceDirectedDelegate new];
  [delegate initWithArgc: argc argv: (char**)argv];
  [app setDelegate: delegate];
  [delegate applyForceDirected: nil];

  //run the application
  [app run];

  //that's it
  [pool release];
  return 0;
}
