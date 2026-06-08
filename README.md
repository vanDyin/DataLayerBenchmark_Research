# iOS Persistence Frameworks Benchmark: Core Data vs SwiftData

This repository contains the source code and experimental setup for a comparative performance analysis of Apple's local data caching and persistence frameworks: **Core Data** and **SwiftData**.

The project evaluates both frameworks under high-intensity data streams (bulk insert operations) on a physical device using precise profiling tools.

## 📊 Executive Summary

The study evaluates bulk cyclic writing of synthetic objects with a fixed schema on a physical **iPhone 15 (Apple A16 Bionic, 6GB RAM, iOS 26.5)**. Measurements were taken in a strict "cold start" environment (the app was purged from RAM, and the database was completely re-created before each run).

### Key Findings:

* 
**Core Data** outperforms SwiftData across all dataset sizes, proving to be **5.5x to 6.0x faster** during batch insertions.


* At extreme workloads (50,000 objects), SwiftData hits a sequential, single-threaded bottleneck caused by its `ObservationRegistrar` queue mechanism, preventing effective parallelization despite high CPU usage.


* 
**Recommendation:** For any heavy write or batch synchronization tasks, **Core Data** with `NSBatchInsertRequest` remains the industry standard. **SwiftData** is best suited for UI-centric apps with lightweight, infrequent data mutations where SwiftUI integration is a priority.



---

## 🛠️ Architecture & Methodology

The project implements a unified **Data Layer** architecture. Both framework modules share an identical interface, isolating the persistence mechanism overhead:

* 
**Core Data:** Uses traditional `NSManagedObjectContext` and direct SQLite interactions.


* 
**SwiftData:** Implements modern `ModelContext` with the `@Model` macro architecture.



### Data Schema

To eliminate inter-object relationship overhead, a minimalistic flat schema was used:

```swift
struct TestObject {
    let id: UUID
    let title: String
    let timestamp: Date
    let value: Double
}

```



### Profiling Tools

* 
**Execution Time:** Measured using a system timer based on the `os.signpost` API with nanosecond precision.


* 
**CPU Load:** Monitored via the **Time Profiler** in Xcode Instruments (1 ms sampling rate).



---

## 📈 Benchmark Results

The data below represents the arithmetic mean calculated across **5 separate launches** for each sample size.

### 1. Execution Time (Lower is Better)

| Framework | 1,000 Objects | 10,000 Objects | 50,000 Objects |
| --- | --- | --- | --- |
| **Core Data** | **18.70 ms** | **99.27 ms** | **473.18 ms** |
| **SwiftData** | 103.67 ms | 576.92 ms | 2865.47 ms |



### 2. Peak CPU Load (Multi-Core Activity)

Note: Values over 100% indicate utilization of multiple CPU cores (with a theoretical max capacity of 600% on the A16 Bionic architecture).

| Framework | 1,000 Objects | 10,000 Objects | 50,000 Objects |
| --- | --- | --- | --- |
| **Core Data** | **166%** | **147%** | **189%** |
| **SwiftData** | 208% | 196% | 190% |

---

## 💻 Tech Stack & Environment

* 
**Language:** Swift 5 


* 
**IDE:** Xcode 26 


* 
**Target OS:** iOS 26.5 


* 
**Hardware:** iPhone 15 (Apple A16 Bionic, 6GB RAM) 



---

## 🏛️ Academic Context

This repository contains the practical experimental component of a university research paper.

* 
**UDK Classification:** 004.4 (Software) 


* 
**Author:** V. A. Polyanskiy (Student, Group IKPI-43, SPbSUT) 


* 
**Institution:** The Bonch-Bruevich Saint-Petersburg State University of Telecommunications 
