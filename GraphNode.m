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
#include "GraphNode.h"

@implementation GraphNode
- (id) init
{
  self = [super init];
  pos = NSZeroPoint;
  connected = [[NSMutableSet alloc] init];
  name = nil;
  return self;
}

- (void) dealloc
{
  NSLog (@"%s", __FUNCTION__);
  [connected release];
  [name release];
  [super dealloc];
}

- (NSPoint) position
{
  return pos;
}

- (void) setPosition: (NSPoint) newPosition
{
  pos = newPosition;
}

- (NSSet *) connectedNodes
{
  return connected;
}

- (void) addConnectedNode: (GraphNode*) n
{
  if ([n isKindOfClass: [GraphNode class]]){
    [connected addObject: n];
  }
}

- (BOOL) isConnectedTo: (GraphNode *) n
{
  return [connected containsObject: n];
}

- (void) setName: (NSString*) newName
{
  name = [newName copy];
}

- (NSString *) description
{
  return [name description];
}
@end
