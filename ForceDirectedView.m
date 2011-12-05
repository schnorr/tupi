/*
    This file is part of ForceDirected.

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
#include "ForceDirectedView.h"
#include "NSPointFunctions.h"

@implementation ForceDirectedView
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  return self;
}

- (void) drawRect: (NSRect)frame
{
  NSAffineTransform* transform = [self transform];
  [transform concat]; 

  NSRect r = NSMakeRect (0,0,10,10);
  [[NSColor redColor] set];
  NSRectFill(r);

  [transform invert];
  [transform concat];
}


- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    [[self window] setAcceptsMouseMovedEvents: YES];
    return YES;
}
@end
