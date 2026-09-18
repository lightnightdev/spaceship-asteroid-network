# spaceship-asteroid-network

A procedural grid generation and network traversal project built with Godot 4.7. While presented as a 2D space-themed movement game, the project primarily serves as a practical implementation of algorithmic spatial partitioning, graph connectivity (Union-Find), and breadth-first pathfinding.

---

## Overview & Key Algorithms

The core mechanics focus on procedural grid generation, network bridging, and analyzing node reachability across orthogonal movement vectors.

* **Logarithmic Density Sampling (`LevelGenerator.gd`)**
  * Utilizes inverse transform sampling (`log(randf()) / log_prob`) to randomly spawn nodes based on a targeted density threshold while avoiding $O(N^2)$ grid iteration overhead.
* **Disjoint-Set / Union-Find Network Cleaning (`NetworkCleaner.gd`)**
  * Groups collinear nodes aligned along horizontal ($X$) and vertical ($Y$) axes into unified networks.
  * Implements Path Compression within the `find` operations to evaluate connected sub-graphs.
  * Ensures level traversal by introducing L-shaped orthogonal bridge nodes across disconnected components.
* **Breadth-First Search & Network Diameter (`NetworkAnalyzer.gd`)**
  * Evaluates graph reachability and distance mapping across 4-directional scan lines.
  * Uses a two-pass BFS algorithm to find the pseudo-diameter of the node graph, identifying the two farthest valid nodes to establish optimal player spawn and goal destination coordinates.
* **Linear Collision Scanning (`GridScanner.gd`)**
  * Simulates line-of-sight vector movement (`scan_jump`) across standard orthogonal directions to calculate collision bounds, landing pads, and trigger zones.

---

## Technical Stack & Configuration

* **Engine:** Godot Engine v4.7
* **Viewport Base Resolution:** 640 × 360 (Integer Scaling, 1280 × 720 Override)

---

## License & Usage Terms

**Copyright © 2026. All Rights Reserved.**

This repository is publicly hosted for portfolio, educational, and demonstration purposes only. 

* **Attribution Required:** You may view, clone, and inspect the source code for learning purposes. If you reference, build upon, or utilize snippets of this codebase in another project, you must retain original credit and link back to this repository.
* **No Unauthorized Redistribution:** You may not copy, re-upload, sublicense, or publish modified forks of this project as standalone works without explicit prior permission.
