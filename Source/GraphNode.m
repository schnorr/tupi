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
#include "GraphNode.h"

@implementation GraphNode
- (id) init
{
  self = [super init];
  pos = NSZeroPoint;
  connected = [[NSMutableSet alloc] init];
  name = nil;
  particle = nil;
  high = NO;
  return self;
}

- (void) dealloc
{
  [connected release];
  [name release];
  [particle release];
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

- (void) removeConnectedNode: (GraphNode *) n
{
  if ([n isKindOfClass: [GraphNode class]]){
    [connected removeObject: n];
  }
}

- (void) removeFromAllConnectedNodes
{
  NSEnumerator *en = [connected objectEnumerator];
  GraphNode *g;
  while ((g = [en nextObject])){
    [g removeConnectedNode: self];
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

- (NSString *) name
{
  return name;
}

- (void) setHighlighted: (BOOL) h
{
  high = h;
}

- (BOOL) highlighted
{
  return high;
}

- (NSRect) boundingBox
{
  return bb;
}

- (void) setBoundingBox: (NSRect) r
{
  bb = r;
}

- (void) setParticle: (Particle*)p
{
  particle = p;
  [particle retain];
}

- (Particle*) particle
{
  return particle;
}
@end
