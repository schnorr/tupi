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
#include "BasicView.h"
#include "NSPointFunctions.h"

@implementation BasicView
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  ratio = 1;
  translate = NSZeroPoint;
  mousePosition = lastMousePosition = NSZeroPoint;
  return self;
}

- (void)scrollWheel:(NSEvent *)event
{
  NSPoint screenPositionAfter, screenPositionBefore, graphPoint;
  NSAffineTransform *t;

  screenPositionBefore = [self convertPoint: [event locationInWindow]
                                   fromView: nil];
  t = [self transform];
  [t invert];
  graphPoint = [t transformPoint: screenPositionBefore];

  //updating the ratio considering 10% of its value 
  if ([event deltaY] > 0){
    ratio += ratio*0.1;
  }else{
    ratio -= ratio*0.1;
  }

  t = [self transform];
  screenPositionAfter = [t transformPoint: graphPoint];

  //update translate to compensate change on scale
  translate = NSAddPoints (translate,
                  NSSubtractPoints (screenPositionBefore, screenPositionAfter));

  [self setNeedsDisplay: YES];
  return;
}

- (void) mouseMoved:(NSEvent *)event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  NSAffineTransform *t = [self transform];
  [t invert];
  lastMousePosition = [t transformPoint: p];

  [self setNeedsDisplay: YES];
}


- (void) mouseDragged:(NSEvent *)event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  NSPoint dif;
  dif = NSSubtractPoints (p, mousePosition);
  if (NSEqualPoints (translate, NSZeroPoint)){
    translate = dif;
  }else{
    translate = NSAddPoints (translate, dif);
  }
  mousePosition = p;

  [self setNeedsDisplay: YES];
}

- (void) mouseDown: (NSEvent *) event
{
  mousePosition = [self convertPoint:[event locationInWindow] fromView:nil];
}

- (void) mouseUp: (NSEvent *) event
{
}

- (NSAffineTransform*) transform
{
  NSAffineTransform* transform = [NSAffineTransform transform];
  [transform translateXBy: translate.x yBy: translate.y];
  [transform scaleXBy: ratio yBy: ratio];
  return transform;
}
@end
