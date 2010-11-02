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

@interface MyDelegate : NSObject
{
  id view;

  int argc;
  char **argv;

  GVC_t *gvc;
  graph_t *graph;
}
- (void) initWithArgc: (int) c argv: (const char**) v;
- (void) applicationDidFinishLaunching: (NSNotification *)not;
- (void) loadFile: (NSString*) filename;
@end

@implementation MyDelegate : NSObject 
- (void) initWithArgc: (int) c argv: (const char**) v
{
  argc = c;
  argv = v; 
}

- (void) applicationDidFinishLaunching: (NSNotification *)not;
{
  [NSBundle loadGSMarkupNamed: @"ForceDirected"  owner: self];

  gvc = gvContext();
  gvParseArgs (gvc, argc, (char**)argv);
  graph = gvNextInputGraph(gvc);
  NSLog (@"layout...");
  gvLayout (gvc, graph, "neato");
  NSLog (@"DONE");
  [view setGVC: gvc];
  [view setGraph: graph];
}

- (void) loadFile: (NSString*) filename
{
}
@end

int main (int argc, const char **argv){
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  //appkit init
  NSApplication *app = [NSApplication sharedApplication];
  MyDelegate *delegate = [MyDelegate new];
  [delegate initWithArgc: argc argv: argv];
  [app setDelegate: delegate];
  if (argc == 2){
    [delegate loadFile: [NSString stringWithFormat: @"%s", argv[1]]];
  }

  //run the application
  [app run];

  //that's it
  [pool release];
  return 0;
}
