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

  //set default line width based on ratio
  [NSBezierPath setDefaultLineWidth: 1/ratio];

  //white fill on view
  [[NSColor whiteColor] set];
  NSRectFill(tela);

  NSAffineTransform* transform = [self transform];
  [transform concat];

  if (gvc && graph){
    Agnode_t *node = agfstnode (graph);
    while (node){
      double x = ND_coord(node).x;
      double y = ND_coord(node).y;
      NSLog (@"%s %f %f", node->name, x, y);
      NSRect r = NSMakeRect (x, y, 10, 10);
      [[NSColor blueColor] set];
      [NSBezierPath fillRect: r];

      Agedge_t *edge = agfstedge (graph, node);
      while (edge){
        NSPoint src, dst;
        src.x = ND_coord(edge->head).x;
        src.y = ND_coord(edge->head).y;
       
        dst.x = ND_coord(edge->tail).x;
        dst.y = ND_coord(edge->tail).y;
       
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint: src];
        [path lineToPoint: dst];
        [path stroke];

        edge = agnxtedge (graph, edge, node);
      }


      node = agnxtnode (graph, node);
    }
  }

  [transform invert];
  [transform concat];
}

- (void) reset: (id) sender
{
  NSLog (@"%s", __FUNCTION__);
  Agnode_t *n1 = agfstnode (graph);
  while (n1){
    ND_coord(n1).x = drand48() * 300;
    ND_coord(n1).y = drand48() * 300;
    n1 = agnxtnode (graph, n1);
  }
  [self setNeedsDisplay: YES];
}

- (void) applyForceDirectedWithSpring: (float) spring
                            andCharge: (float) charge
                          andDamping: (float) damping
{
  NSLog (@"%s", __FUNCTION__);
  Agnode_t *n1, *n2;
  n1 = agfstnode (graph);
  while (n1){
    double n1dx = 0;
    double n1dy = 0; 

    n2 = agfstnode (graph);
    while (n2){
      double dx = ND_coord(n2).x - ND_coord(n1).x;
      double dy = ND_coord(n2).y - ND_coord(n1).y;
      double hypotenuse = hypot (dx, dy);
      double force = 0;
      if (n1 != n2){ 
        if (agfindedge (graph, n1, n2)){
          //connected
          force = (hypotenuse - spring) / 2.0;
        }else{
          //NOT connected
          force = - (100 / hypotenuse * hypotenuse) * charge;
        }
        dx /= hypotenuse;
        dy /= hypotenuse;
        dx *= force;
        dy *= force;
        n1dx += dx;
        n1dy += dy;
      }
      n2 = agnxtnode (graph, n2);
    }
    ND_coord(n1).x += n1dx;
    ND_coord(n1).y += n1dy;

    n1 = agnxtnode (graph, n1);
  }
  [self setNeedsDisplay: YES];
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
  [self forceDirectedWithSpring: 1
                      andCharge: 1
                     andDamping: 0.5];

}

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
