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
#include "Tupi.h"
#include "GraphNode.h"

@implementation Tupi
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

  //allocate space to keep all loaded graph nodes from file
  graph = [[NSMutableDictionary alloc] init];

  //allocate the particle system
  layout = [[Layout alloc] init];

  //read all nodes from file, put them in the particle system
  [dotFile = [args objectAtIndex: 1] retain];
  [self loadAllNodesFromFile: dotFile];

  //run the particle system runner
  layoutRunner = [[LayoutRunner alloc] init];
  [layoutRunner setLayout: layout];
  [layoutRunner setProvider: self];
  thread = [[NSThread alloc] initWithTarget: layoutRunner
                                   selector: @selector(run:)
                                     object: self];
  [thread start];

  //default for showing cells
  showBarnesHutCells = NO;
}

- (void) loadAllNodesFromFile: (NSString *) dot
{
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

  //add all loaded nodes to the particle system
  NSEnumerator *en = [self graphNodesEnumerator];
  GraphNode *n;
  while ((n = [en nextObject])){
    [layout addNode: n withName: [n name]];
  }
}

- (void) applicationDidFinishLaunching: (NSNotification *)not
{
  if (![NSBundle loadGSMarkupNamed: @"Tupi"  owner: self]){
    [[NSApplication sharedApplication] terminate:self];
  }
  [window makeKeyAndOrderFront: self];
  [window setDelegate: self];
  [window setAcceptsMouseMovedEvents:YES];
  [view setProvider: self];
  [view setLayout: layout];
  [view setNeedsDisplay: YES];
}

- (BOOL) windowShouldClose: (id) sender
{
  [[NSApplication sharedApplication] terminate:self];
  return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
}

- (void) thread: (id) sender
{
  if (thread != nil && [thread isExecuting]){
    [thread cancel];
    [thread release];
    thread = nil;
  }else{
    thread = [[NSThread alloc] initWithTarget: layoutRunner
                                     selector: @selector(run:)
                                       object: self];
    [thread start];
  }
}

- (void) shake: (id) sender
{
  [layout shake];
}

- (void) reset: (id) sender
{
  NSEnumerator *en = [self graphNodesEnumerator];
  GraphNode *node;
  while ((node = [en nextObject])){
    [self removeNode: node];
  }
  [self loadAllNodesFromFile: dotFile];
}

- (void) cells: (id) sender
{
  showBarnesHutCells = !showBarnesHutCells;
  [view setNeedsDisplay: YES];
}

- (void) removeNode: (id<FDNode>) g
{
  //disconnect the node from all connected nodes
  [g removeFromAllConnectedNodes];

  //remove the corresponding particle from the layout
  [layout removeNode: g];

  //final removal from node dictionary
  [graph removeObjectForKey: [g name]];
}

- (void) startMovingNode: (id<FDNode>) node
{
  [layout freezeNode: node frozen: YES];
}

- (void) moveNode: (id<FDNode>) node toLocation: (NSPoint) newLocation
{
  [layout moveNode: node toLocation: newLocation];
  [layout freezeNode: node frozen: YES];
  return;
}

- (void) stopMovingNode: (id<FDNode>) node
{
  [layout freezeNode: node frozen: NO];
}

- (BOOL) barnesHutCells
{
  return showBarnesHutCells;
}
@end
