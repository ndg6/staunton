// The diagram / table outlines export as an HTML navigation landmark
// (<nav role="doc-toc">) with in-document links to each captioned figure.
// HTML-HAS: doc-toc
// HTML-HAS: List of Diagrams
// HTML-HAS: href="#
#import "/lib.typ": diagram, chess-diagram-outline
#diagram("4k3/8/8/8/8/8/8/4K3", caption: [First.], size: 3cm)
#diagram("8/8/8/8/8/8/8/4K1k1", caption: [Second.], size: 3cm)
#chess-diagram-outline()
