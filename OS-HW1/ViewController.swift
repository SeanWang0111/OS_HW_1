//
//  ViewController.swift
//  OS-HW1
//
//  Created by 王奕翔 on 2022/10/25.
//

import UIKit

class ViewController: UIViewController {
    
    private var aArray = [[Double]]()
    private var bArray = [[Double]]()
    private var c_for_array = [[Double]]()
    private var c_50_array = [[Double]]()
    private var c_10_array = [[Double]]()
    
    // a 列
    private var a_i_count: Int = 500
    // a 行
    private var a_j_count: Int = 800
    
    // b 列
    private var b_i_count: Int = 800
    // b 行
    private var b_j_count: Int = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrayInit()
    }
    
    /// 陣列初始化
    private func arrayInit() {
        let mainQueue = DispatchQueue.main
        let secQueue = DispatchQueue.global()
        let groupQueue = DispatchGroup()
        let initStart = CFAbsoluteTimeGetCurrent()
        
        secQueue.async(group: groupQueue) {
            for i in 0..<self.a_i_count {
                var row = [Double]()
                for j in 0..<self.a_j_count {
                    /// 6.6i - 3.3j
                    row.append(6.6 * Double(i + 1) - 3.3 * Double(j + 1))
                }
                self.aArray.append(row)
            }
//            dump("A陣列： \(aArray)")
        }
        
        secQueue.async(group: groupQueue) {
            for i in 0..<self.b_i_count {
                var row = [Double]()
                for j in 0..<self.b_j_count {
                    /// 100 + 2.2i - 5.5j
                    row.append(Double(100) + 2.2 * Double(i + 1) - 5.5 * Double(j + 1))
                }
                self.bArray.append(row)
            }
//            dump("B陣列： \(bArray)")
        }
        
        groupQueue.notify(queue: mainQueue) {
            let initEnd = CFAbsoluteTimeGetCurrent()
            print("陣列初始時間：\((initEnd - initStart) * 1000) 毫秒")
            self.threads50()
        }
    }
    
    /// 迴圈
    private func forLoop() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for i in 0..<a_i_count {
            let matrixlRow: [Double] = aArray[i]
            var row = [Double]()
            
            for bj in 0..<b_j_count {
                var matrix2Col = [Double]()
                
                for bi in 0..<b_i_count {
                    matrix2Col.append(bArray[bi][bj])
                }
                
                let dotValue: Double = doDot(v1: matrixlRow, v2: matrix2Col)
                row.append(dotValue)
            }
            c_for_array.append(row)
        }
        let endTime = CFAbsoluteTimeGetCurrent()
        print("for_loop陣列時間：\((endTime - startTime) * 1000) 毫秒")
//        dump("for_loop陣列： \(c_for_array)")
    }
    
    /// 執行緒 50
    private func threads50() {
        let mainQueue = DispatchQueue.main
        let secQueue = DispatchQueue.global()
        let groupQueue = DispatchGroup()
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for i in 0..<a_i_count {
            let matrixlRow: [Double] = aArray[i]
            var row = [Double]()
            
            secQueue.async(group: groupQueue) {
                for bj in 0..<self.b_j_count {
                    var matrix2Col = [Double]()
                    
                    for bi in 0..<self.b_i_count {
                        matrix2Col.append(self.bArray[bi][bj])
                    }
                    
                    let dotValue: Double = self.doDot(v1: matrixlRow, v2: matrix2Col)
                    row.append(dotValue)
                }
                self.c_50_array.append(row)
            }
        }
        
        groupQueue.notify(queue: mainQueue) {
            let endTime = CFAbsoluteTimeGetCurrent()
            print("執行緒50陣列時間：\((endTime - startTime) * 1000) 毫秒")
//            dump("執行緒50陣列： \(c_50_array)")
            self.threads10()
        }
    }
    
    /// 執行緒10
    private func threads10() {
        let mainQueue = DispatchQueue.main
        let secQueue = DispatchQueue.global()
        let groupQueue = DispatchGroup()
        let startTime = CFAbsoluteTimeGetCurrent()
        /// 分成  5 X 2 塊
        /// Ex:  結果為 50 X 50
        /// 十個執行緒分別的起始點為 (0, 0), (0, 25). (10, 0), (10, 25). (20, 0), (20, 25). (30, 0), (30, 25). (40, 0), (40, 25)
        for X in 0..<5 {
            for Y in 0..<2 {
                secQueue.async(group: groupQueue) {
                    for a_i in 0..<(self.a_i_count / 5) {
                        let matrixlRow: [Double] = self.aArray[X * (self.a_i_count / 5) + a_i]
                        var row = [Double]()
                        
                        for b_j in 0..<(self.b_j_count / 2) {
                            var matrix2Col = [Double]()
                            
                            for bi in 0..<self.b_i_count {
                                matrix2Col.append(self.bArray[bi][Y * (self.b_j_count / 2) + b_j])
                            }
                            
                            let dotValue: Double = self.doDot(v1: matrixlRow, v2: matrix2Col)
                            row.append(dotValue)
                        }
                        self.c_10_array.append(row)
                    }
                }
            }
        }
        
        groupQueue.notify(queue: mainQueue) {
            let endTime = CFAbsoluteTimeGetCurrent()
            print("執行緒10陣列時間：\((endTime - startTime) * 1000) 毫秒")
//            dump("執行緒10陣列： \(c_10_array)")
            self.forLoop()
        }
    }
    
    /// 陣列乘積
    private func doDot(v1: [Double], v2: [Double]) -> Double {
        var dotValue: Double = 0
        for i in 0..<a_j_count {
            dotValue += v1[i] * v2[i]
        }
        return dotValue
    }
}

