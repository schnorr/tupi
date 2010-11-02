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
/* All Rights reserved */

#include "DrawView.h"

@implementation DrawView
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  return self;
}

- (BOOL) isFlipped
{
    return NO;
}

- (void)drawRect:(NSRect)frame
{
  NSRect tela = [self bounds];

  //white fill on view
  [[NSColor whiteColor] set];
  NSRectFill(tela);

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

/*
- (void) mouseDragged:(NSEvent *)event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  if (selectingArea){
    NSAffineTransform *t = [self transform];
    [t invert];
    NSPoint b = [t transformPoint: p];
    NSPoint a = selectedArea.origin;
 
    NSPoint origin, diagonal;
    NSSize size;
 
    if (b.x == a.x || b.y == a.y) return;
 
    if (b.x > a.x && b.y > a.y) {
      //top right
      origin = a;
      diagonal = b;
    } else if (b.x < a.x && b.y < a.y) {
      //bottom left
      origin = b;
      diagonal = NSMakePoint(a.x+selectedArea.size.width, a.y+selectedArea.size.height);
    } else if (b.x > a.x && b.y < a.y){
      //bottom right
      origin = NSMakePoint (a.x, b.y);
      diagonal = NSMakePoint (b.x, a.y + selectedArea.size.height);
    } else if (b.x < a.x && b.y > a.y) {
      //top left
      origin = NSMakePoint (b.x, a.y);
      diagonal = NSMakePoint (a.x + selectedArea.size.width, b.y);
    }
 
    size.width = diagonal.x - origin.x;
    size.height = diagonal.y - origin.y;
 
    selectedArea.origin = origin;
    selectedArea.size = size;
 
    [self setNeedsDisplay: YES];
  }

  if (movingSingleNode){
    //code for changing the position of a node
    if (selectedNode == nil) {
      return;
    }

    NSAffineTransform *t = [self transform];
    [t invert];
    NSPoint p2 = [t transformPoint: p];

    NSRect nodebb = [selectedNode bb];
    nodebb.origin.x = p2.x - nodebb.size.width/2;
    nodebb.origin.y = p2.y - nodebb.size.height/2;
    [selectedNode setBoundingBox: nodebb];
  }else{
    NSPoint dif;
    dif = NSSubtractPoints (p, move);
    if (NSEqualPoints (translate, NSZeroPoint)){
      translate = dif;
    }else{
      translate = NSAddPoints (translate, dif);
    }
    move = p;
  }
  [self setNeedsDisplay: YES];
}

- (void) mouseDown: (NSEvent *) event
{
  move = [self convertPoint:[event locationInWindow] fromView:nil];

  if ([event modifierFlags] & NSControlKeyMask){
    if (selectedNode != nil){
      //moving a single node
      movingSingleNode = YES;
    }else{
      //selecting area
      selectingArea = YES;
      NSAffineTransform *t = [self transform];
      [t invert];
      NSPoint pt = [t transformPoint: move];
      selectedArea.origin = pt;
      selectedArea.size = NSZeroSize;
    }
  }
}

- (void) mouseUp: (NSEvent *) event
{
  if (selectingArea){
    //do multiple node selection
  }

  selectingArea = NO;
  movingSingleNode = NO;
}

- (void) mouseMoved:(NSEvent *)event
{
  NSPoint p, p2;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  NSAffineTransform *t = [self transform];
  [t invert];
  p2 = [t transformPoint: p];

  //search for selected areas
  if (NSPointInRect (p2, selectedArea)){
    highlightSelectedArea = YES;
  }else{
    highlightSelectedArea = NO;
  }
  [self setNeedsDisplay: YES];

  //search for nodes
  ForceDirectedGraphNode *node;
  NSEnumerator *en = [filter enumeratorOfNodes];
  BOOL found = NO;
  while ((node = [en nextObject])){
    if([node mouseInside: p2]){
      if (selectedNode){
        [selectedNode setHighlight: NO];
      }
      selectedNode = node;
      [selectedNode setHighlight: YES];
      [self setNeedsDisplay: YES];
      found = YES;
      break;
    }
  }
  if (!found){
    if (selectedNode){
      [selectedNode setHighlight: NO];
      selectedNode = nil;
      [self setNeedsDisplay: YES];
    }
  }else{
    return;
  }

  //search for edges
  ForceDirectedGraphEdge *edge = nil;
  en = [filter enumeratorOfEdges];
  found = NO;
  while ((edge = [en nextObject])){
    if ([edge mouseInside: p2]){
      if (selectedEdge){
        [selectedEdge setHighlight: NO];
        selectedEdge = nil;
      }
      selectedEdge = edge;
      [selectedEdge setHighlight: YES];
      [self setNeedsDisplay: YES];
      found = YES;
      break;
    }
  }
  if (!found){
    if (selectedEdge){
      [selectedEdge setHighlight: NO];
      selectedEdge = nil;
      [self setNeedsDisplay: YES];
    }
  }
}

- (void)scrollWheel:(NSEvent *)event
{
  if (([event modifierFlags] & NSControlKeyMask)){
    //change the scale of the drawing (used by GraphConfiguration filter)
    if ([event deltaY] > 0){
      scale += scale*0.1;
    }else{
      scale -= scale*0.1;
    }
    [filter graphComponentScalingChanged];
  }else{
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
  [self setNeedsDisplay: YES];
}

- (void) printGraph
{
  static int counter = 0;
  NSPrintOperation *op;
  NSMutableData *data = [NSMutableData data];
  op = [NSPrintOperation EPSOperationWithView: self
                                   insideRect: [self bounds]
                                       toData: data];
  [op runOperation];
  NSString *filename = [NSString stringWithFormat: @"%03d-graph-%@-%@.eps",
    counter++, [filter selectionStartTime], [filter selectionEndTime]];
  [data writeToFile: filename atomically: YES];
  NSLog (@"screenshot written to %@", filename);
}

- (void)keyDown:(NSEvent *)theEvent
{
  if (([theEvent modifierFlags] | NSAlternateKeyMask) &&
    [theEvent keyCode] == 33){ //ALT + P
    [self printGraph];
  }else if (([theEvent modifierFlags] | NSAlternateKeyMask) &&
    [theEvent keyCode] == 26){

    ForceDirectedGraphNode *node;
    NSEnumerator *en = [filter enumeratorOfNodes];
    while ((node = [en nextObject])){
      NSPoint p = [node bb].origin;
      NSLog (@"%@ = { x = %f; y = %f; };", [node name], p.x, p.y);
    }
    NSRect rect = [filter sizeForGraph];
    NSLog (@"Area = { x = %f; y = %f; width = %f; height = %f; };",
      rect.origin.x,
      rect.origin.y,
      rect.size.width,
      rect.size.height);
  }else if (([theEvent modifierFlags] | NSAlternateKeyMask) &&
    [theEvent keyCode] == 27){ //ALT + R
    [filter setRecordMode];
  }
}

- (double) scale
{
  return scale;
}
*/
@end
