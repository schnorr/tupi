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
      NSRect r = NSMakeRect (x, y, 10, 10);
      [[NSColor blueColor] set];
      [NSBezierPath fillRect: r];
      [[NSString stringWithFormat: @"%s", node->name]
               drawAtPoint: NSMakePoint(x+10,y+10)
                    withAttributes: nil];

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

  [NSStringFromPoint(lastMousePosition) drawAtPoint: NSMakePoint (tela.size.width/2, tela.size.height-20)
                                  withAttributes: nil];
}

- (void) reset: (id) sender
{
  Agnode_t *n1 = agfstnode (graph);
  while (n1){
    ND_coord(n1).x = drand48() * 300;
    ND_coord(n1).y = drand48() * 300;
    n1 = agnxtnode (graph, n1);
  }
  [self setNeedsDisplay: YES];
}

- (double) applyForceDirectedWithSpring: (float) spring
                            andCharge: (float) charge
                          andDamping: (float) damping
{
  Agnode_t *n1, *n2;

  // set up initial node velocities to (0,0)
  n1 = agfstnode (graph);
  while (n1){
    agsafeset (n1, "dx", "0", "0");
    agsafeset (n1, "dy", "0", "0");
    n1 = agnxtnode (graph, n1);
  }

  // running sum of total kinetic energy over all particles
  NSPoint total_kinetic_energy = NSMakePoint (0,0);
//  NSPoint old_total_kinetic_energy = NSMakePoint (0,0);
  int i = 0;
//  do {
    total_kinetic_energy = NSMakePoint(0,0);
    n1 = agfstnode (graph);
    while (n1){
      // running sum of total force on this particular node
      NSPoint force = NSMakePoint (0, 0);

      n2 = agfstnode (graph);
      while (n2){
        //distance between particles
        NSPoint n1p = NSMakePoint (ND_coord(n1).x, ND_coord(n1).y);
        NSPoint n2p = NSMakePoint (ND_coord(n2).x, ND_coord(n2).y);
        NSPoint dif = NSSubtractPoints (n1p, n2p);
        double distance = LMSDistanceBetweenPoints (n1p, n2p);

        if (n1 != n2){
          //calculate coulomb repulsion and hooke attraction
          double coulomb_repulsion = 0;
          double hooke_attraction = 0; 

          //coulomb_repulsion (k_e * (q1 * q2 / r*r))
          double coulomb_constant = 1;
          double r = distance;
          double q1 = charge;
          double q2 = charge;
          coulomb_repulsion = coulomb_constant * (q1*q2)/(r*r);
 
          if (agfindedge (graph, n1, n2)){
            //hooke_attraction (-k * x)
            hooke_attraction = 1 - (fabs (distance - spring) / spring);
          }
          force = NSAddPoints (force, LMSMultiplyPoint (LMSNormalizePoint(dif), coulomb_repulsion));
          force = NSAddPoints (force, LMSMultiplyPoint (LMSNormalizePoint(dif), hooke_attraction));
        }
        n2 = agnxtnode (graph, n2);
      }
      NSPoint velocity = NSMakePoint (atof(agget (n1, "dx")), atof(agget (n1, "dy")));
      velocity = NSAddPoints (velocity, force);
      velocity = LMSMultiplyPoint (velocity, damping);

      ND_coord(n1).x = ND_coord(n1).x + velocity.x;
      ND_coord(n1).y = ND_coord(n1).y + velocity.y;

      //save velocity?

      total_kinetic_energy = NSAddPoints (total_kinetic_energy, velocity); 

      n1 = agnxtnode (graph, n1);
    }

//    NSLog (@"total_kinetic_energy = %@, old = %@",  NSStringFromPoint(total_kinetic_energy), NSStringFromPoint(old_total_kinetic_energy));
//    if (NSEqualPoints (old_total_kinetic_energy, total_kinetic_energy)) break;

 //   old_total_kinetic_energy = total_kinetic_energy;
    i++;

    [self setNeedsDisplay: YES];
    return fabs(total_kinetic_energy.x) + fabs(total_kinetic_energy.y);

//  }while (fabs(total_kinetic_energy.x + total_kinetic_energy.y) > 0.001);// && i < 1000);
}

- (void) exportPositions
{
  double minx = FLT_MAX, miny = FLT_MAX;
  double maxx = -FLT_MAX, maxy = -FLT_MAX;

  Agnode_t *n1;

  NSLog (@"These are the coordinates: ");

  //find minx, maxx
  //find miny, maxy
  n1 = agfstnode (graph);
  while (n1){
    double x = ND_coord(n1).x;
    double y = ND_coord(n1).y;
    if (x < minx) minx = x;
    if (x > maxx) maxx = x;
    if (y < miny) miny = y;
    if (y > maxy) maxy = y;
    n1 = agnxtnode (graph, n1);
  }

  fprintf (stderr, "Area = { x = 0; y = 0; width = %f; height = %f; }\n",
      maxx-minx, maxy-miny);

  //output coordinates
  n1 = agfstnode (graph);
  while (n1){
    double x = ND_coord(n1).x - minx;
    double y = ND_coord(n1).y - miny;
    fprintf (stderr, "%s = { x = %f; y = %f; }\n", n1->name, x, y);
    n1 = agnxtnode (graph, n1);
  }
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

*/
- (void) mouseMoved:(NSEvent *)event
{
  NSPoint p;
  p = [self convertPoint:[event locationInWindow] fromView:nil];

  NSAffineTransform *t = [self transform];
  [t invert];
  lastMousePosition = [t transformPoint: p];

  [self setNeedsDisplay: YES];
/*
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
*/
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
