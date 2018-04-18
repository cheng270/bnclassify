# all functions with begin wit graph_ 
# Nodes + edge list. 

# TODO: implement the interfac of dag.r.  
# TODO: also cover anb-families. Most of it anyway. Because no need for ANB specifics here. That is, the class variable is indistinct here.
# However, soma of anb-families will probably go away.

# TODO: the matrix list should contain integers, not strings, to avoid back and forth with boost
#     a print function could translate the integers to strings
# 
# nodes()
# add ..
# I only need boost for algorithms and things I do not implement
# is_dag() : here call  the acyclic check   

# /**
#  * Basic adjacency list object api
#  * Data:
#  *  mapping from names to ids.
#  *  Matrix of edges between
#  * adj_list {
#  *    string_vec nodes : all the string nodes I need.
#  *    edge matrix: uses ids as entries
#  *   public
#  *    int vec ids():
#  *    edgeMatrix(names=FALSE): uses ids as entries
#  *    edgeMatrix(names=FALSE): uses names as entries
#  *    print(): print nicely
#  * }
#  */   
graph_internal <- function(nodes, edges) {  
    stopifnot(is.character(nodes), is.character(edges), is.matrix(edges))
    edges <- graph_make_edges(nodes, edges)
    graph_internal_make (nodes, edges) 
}
graph_internal_make <- function(nodes, edges) {   
    stopifnot(is.character(nodes), is.numeric(edges), is.matrix(edges))
    dag <- list(nodes=nodes, edges=edges) 
    class(dag) <- 'bnc_graph_internal'
    dag
}
graph_nodes <- function(x) {
  stopifnot(is( x, "bnc_graph_internal"))
  x$nodes 
}
graphNEL2_graph_internal <- function(x) { 
  stopifnot(inherits(x, "graphNEL"))
  nodes <- graph::nodes(x)
  edges <- named_edge_matrix(x)
  graph_internal(nodes, edges ) 
}  
graph_internal2graph_NEL <- function(x) {  
  stopifnot(inherits( x, "bnc_graph_internal")) 
  edges <- graph_named_edge_matrix(x) 
  graph::ftM2graphNEL(ft = edges, W = NULL, V = x$nodes, edgemode = "directed")  
} 
graph_make_edges <- function(nodes, edges) { 
  stopifnot(is.character(nodes), is.character(edges), nrow(edges) == 2)
  from <- match(edges[1, ], nodes) - 1
  to <- match(edges[2, ], nodes) - 1
  edges <- matrix(c(from, to), ncol = 2)
  edges 
}  
call_bh <- function(fun, g, ...) { 
 do.call(fun, args = list(vertices = g$nodes, edges  = g$edges, ...)) 
}
#'  connected_components 
#'  
#'  @param  x currently a graphNEL. TODO But will be a graph_internal.
#'  @keywords internal
graph_connected_components <- function(x) {  
  g <- graphNEL2_graph_internal(x)
  stopifnot(inherits(g, "bnc_graph_internal"))  
  connected <- call_bh('bh_connected_components', g)
  comps <- split(graph_nodes(g), connected + 1)
  # TODO remove this. 
  if (length(comps) > 0) {
    comps 
  } 
  else {
    NULL
  }
} 
#'  Subgraph.  
#'  Only for a directed graph?
#'  @param  x currently a graphNEL. TODO But will be a graph_internal.
#'  @keywords internal
graph_subgraph <- function(nodes, x) { 
  g <- graphNEL2_graph_internal(x)
  stopifnot(inherits(g, "bnc_graph_internal"))   
  subgraph <- call_bh('bh_subgraph', g = g,  subgraph_vertices = nodes) 
  subgraph <- graph_internal_make(subgraph$nodes, subgraph$edges)
  # TODO remove:
  graph_internal2graph_NEL(subgraph ) 
}  
# No need to call BGL for this. 
graph_add_node <- function(node, x) { 
  g <- graphNEL2_graph_internal(x)
  stopifnot(inherits( g, "bnc_graph_internal"), is.character(node)) 
  if (node %in% g$nodes) stop("Node already in graph") 
  g$nodes <- c(g$nodes, node)  
  graph_internal2graph_NEL(g) 
}
graph_remove_node <- function(node, x) {
  g <- graphNEL2_graph_internal(x) 
  stopifnot(inherits( g, "bnc_graph_internal"), is.character(node))  
  if (!node %in% g$nodes) stop("Node not in graph")  
  removed <- call_bh('bh_remove_node', g = g, remove = node)  
  removed <- graph_internal_make(removed$nodes, removed$edges)
  graph_internal2graph_NEL(removed) 
}
graph_num_arcs <- function(x) { 
  g <- graphNEL2_graph_internal(x)
  stopifnot(inherits( g, "bnc_graph_internal")) 
  nrow(g$edges)
}
graph_num_nodes <- function(x) { 
  # TODO: if not...
  g <- graphNEL2_graph_internal(x)
  stopifnot(inherits( g, "bnc_graph_internal")) 
  length(g$nodes)
}
graph_parents <- function(x) {  
  g <- graphNEL2_graph_internal(x)
  stopifnot(inherits( g, "bnc_graph_internal"))  
  nnodes <- graph_num_nodes(g)
  if (nnodes == 0) return(list())
  parents <- setNames(replicate(nnodes, character()), graph_nodes(g))
  if (graph_num_arcs(g) == 0) return(parents)
  edges <- graph_named_edge_matrix(g) 
  have_parents <- tapply(unname(edges['from',]), unname(edges['to', ]),
                         identity, simplify = FALSE)
  parents[names(have_parents)] <- have_parents
  parents  
}   
#' Returns an edge matrix with node names (instead of node indices).
#' 
#' @return A character matrix. 
#' @keywords internal
graph_named_edge_matrix <- function(x) { 
  u <-  x$edges
  u[] <- x$nodes[as.vector(u) + 1]
  if (length(u) == 0) mode(u) <- 'character'
  stopifnot(is.character(u))
  u
}