# GIS Simulator

Yet another push towards the idea of a Monte Carlo simulation of GIS transactions. This one might cross the line.

## The Problem

The foundation of this is the work by Dave Peters at Esri in the late '90s through to his retirement. His work with the Capacity Planning Tool allowed GIS architects to compute the complex relationships among:

1. What types of users were accessing the system
1. What types of services were they accessing
1. Where were they accessing them from
1. How often (how productive were they)

Everyone acknowledges that the CPT was too complex for most people to use. It is a very complex Excel spreadsheet. There have been other attempts to bring the ideas of the CPT to ordinary folks, including the [System Designer](https://www.arcgis.com/home/item.html?id=8ff490eef2794f428bde25b561226bda) tool for Windows, and recently the Basic Capacity Planner spreadsheet. These each have their drawbacks:

- System Designer runs on Windows only and requires a SQL Server Lite instance to save its data. It also has what I consider a couple of main design failures:
	1. The hierarchical structure in the tree view does not actually represent the logical structure of the data in the model, leading to confusion.
	1. It requires a lot of work to get to the point where the user can start calculating capacity. I have found it took at least a day or two to get a representative model. That's fine if you only work with one system (i.e. you are a system owner) but not so good for consulting.
- The Basic Capacity Planner is a spreadsheet and it really is a lot simpler, but it gains its simplicity by removing most of the calculations in the CPT.
	1. It does not provide system response times, queue times, network transfer times, and all of the insights that those stats bring.
	1. It really counts users and server types and then gives you rough numbers of VMs to cover it.

The CPT also has significant issues, the chief of which is no one is maintaining it any more. Others include:
1. The aforementioned complexity.
1. It does not handle workflows that have many parallel requests well. A simple example is a web map that has one hosted layer and one basemap. The hosted layer may be coming from ArcGIS Enterprise, while the basemap comes from ArcGIS Online. Each refresh sends requests to two separate systems.
1. It uses statistics to try to calculate the effect of random arrival times for requests.

## The Idea and the History to Date

I was talking with Dave Horwood at Tech Trek (it might have been in 2015) and we were discussing the CPT. Dave suggested that it would be cool to have a Monte Carlo simulation at the heart of the CPT. This would theoretically provide results that were more of a simulation and less of a spreadsheet abstraction.

Since then, the idea has been rattling around in my head. I have chewed on the idea and wrote proofs of concept in Perl, Swift and most recently in Scala. Each time I kept running into roadblocks where short-sighted design decisions caused big problems later. I thought I had it licked when I wrote CPSimCore in Swift in 2021. But then some of the things I'd done made it impractical to actually write a user interface for it.

Redoing in Scala forced me to think in a different way. Where was my state? What could be immutable? It really changed the fundamental design (in a good way), but then I ran into the state of the art (or lack thereof) of Java desktop app developer tools.

## GIS Simulator

I took the clean Engine design from the Scala code and ported it to Swift, with the intent of creating a UIKit-based iPad app. It could have theoretically been an AppKit app or a SwiftUI app, but I'm going with my strengths.

Porting went well, and I adopted Swift's value semantics of copy-on-write instead of forcing Scala-like immutable data structures.
