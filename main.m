/*
    This file is part of Tupi

    Tupi is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Tupi is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Tupi.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>
#include <graphviz/types.h>
#include <graphviz/graph.h>
#include <sys/time.h>
#include "GraphNode.h"
#include "Layout.h"
#include "LayoutRunner.h"
#include "FDView.h"

double gettime ()
{
        struct timeval tr;
        gettimeofday(&tr, NULL);
        return (double)tr.tv_sec+(double)tr.tv_usec/1000000;
}


@interface Fd : NSObject
{
  id window;
  id view;
  NSMutableDictionary *graph;
  Layout *layout;
}
@end

@implementation Fd
- (NSEnumerator *) graphNodesEnumerator
{
  return [graph objectEnumerator];
}

- (NSEnumerator *) particlesEnumerator
{
  return [[layout allParticles] objectEnumerator];
}

- (NSRect) boundingBox
{
  return [layout boundingBox];
}

- (void) layoutChanged
{
  [view setNeedsDisplay: YES];
}

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

    Agnode_t *n2;
    for (n2 = agfstnode (g); n2; n2 = agnxtnode (g, n2)){
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

  //Here
  layout = [[Layout alloc] init];
  [layout setProvider: self];
  NSEnumerator *en = [graph objectEnumerator];
  GraphNode *n;
  while ((n = [en nextObject])){
    [layout addNode: n withName: [n name]];
  }

  LayoutRunner *fd = [[LayoutRunner alloc] init];
  [fd setLayout: layout];
  [fd setProvider: self];
  [[[NSThread alloc] initWithTarget: fd
                           selector: @selector(run:)
                             object: nil] start];

//  [[NSApplication sharedApplication] terminate:self];
}

- (void) applicationDidFinishLaunching: (NSNotification *)not
{
  if (![NSBundle loadGSMarkupNamed: @"Tupi"  owner: self]){
    [[NSApplication sharedApplication] terminate:self];
  }
  [window makeKeyAndOrderFront: self];
  [window setDelegate: self];
  [view setProvider: self];
  [view setNeedsDisplay: YES];
}

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
  NSLog (@"leaving...");
}
@end

int main (int argc, const char **argv)
{
  aginit();
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSApplication *app = [NSApplication sharedApplication];
  Fd *delegate = [Fd new];
  [app setDelegate: delegate];

  RELEASE(pool);
  return NSApplicationMain (argc, argv);
}

