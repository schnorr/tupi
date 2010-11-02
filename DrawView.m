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
#include "NSPointFunctions.h"

@implementation DrawView
- (id) initWithFrame: (NSRect) frame
{
  self = [super initWithFrame: frame];
  gvc = NULL;
  graph = NULL;
  ratio = 1;
  return self;
}

- (void) setGVC: (GVC_t *) g
{
  gvc = g;
}

- (void) setGraph: (graph_t *) g
{
  graph = g;
}

- (NSAffineTransform*) transform
{
  NSAffineTransform* transform = [NSAffineTransform transform];
  [transform translateXBy: translate.x yBy: translate.y];
  [transform scaleXBy: ratio yBy: ratio];
  return transform;
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

  NSAffineTransform* transform = [self transform];
  [transform concat];

  NSRect r = NSMakeRect(0,0,10,10);
  [[NSColor blueColor] set];
  [NSBezierPath fillRect: r];

  if (gvc && graph){
    Agnode_t *node = agfstnode (graph);
    while (node){
      double x = ND_coord(node).x;
      double y = ND_coord(node).y;
      NSRect r = NSMakeRect (x, y, 10, 10);
      [NSBezierPath fillRect: r];

      node = agnxtnode (graph, node);
    }
  }

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

- (void) mouseDragged:(NSEvent *)event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  NSPoint dif;
  dif = NSSubtractPoints (p, move);
  if (NSEqualPoints (translate, NSZeroPoint)){
    translate = dif;
  }else{
    translate = NSAddPoints (translate, dif);
  }
  move = p;
  
  [self setNeedsDisplay: YES];
}

- (void) mouseDown: (NSEvent *) event
{
  move = [self convertPoint:[event locationInWindow] fromView:nil];
}

/*
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
*/

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

/*
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
