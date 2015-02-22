//
// Queue.swift
// NTBSwift
//
// Created by Kåre Morstøl on 11/07/14.
//
// Using the "Two-Lock Concurrent Queue Algorithm" from http://www.cs.rochester.edu/research/synchronization/pseudocode/queues.html#tlq, without the locks.



class Queue {
    
    var myQueue: [AnyObject] = []
    
    var queueSize: Int
    
    init(queueSize: Int) {
        
        self.queueSize = queueSize
        
    }
    
    func push(object:AnyObject) {
        
        if (myQueue.count > queueSize) {
            myQueue.removeLast()
            myQueue.append(object)
        }
        
    }
    
}