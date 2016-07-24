//  Netter.swift
//
//  Copyright (c) 2016 Maximilian A. Giraldo
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

public enum NetterRequestMethod {
	case GET
	case POST
}

public struct NetterStatusCodes {
	static let Success = 200
	static let NotFound = 404
	static let InternalServerError = 500

}

public enum NetterDataResult {
	case Success(AnyObject?)
	case Failure(String?)
}

public class Netter {
	
	public init() {}
	
	/**
	Returns a request for use in NSURLSession#dataTaskWithRequest
	- parameter requestMethod:  A NetterRequestMethod enum, which can be either .Get or .Post
	- returns: NSMutableURLRequest?
	*/
	public static func requestFactory(requestMethod: NetterRequestMethod) -> NSMutableURLRequest? {
		let request = NSMutableURLRequest()
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		
		switch requestMethod {
		case .GET:
			request.HTTPMethod = "GET"
			request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		case .POST:
			request.HTTPMethod = "POST"
			request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
		default:
			return nil
		}
		
		return request
	}
	
	/**
	Returns AnyObject? from NSJSONSerialization.JSONObjectWithData, which you can then cast to whatever type you want, e.g. [NSDictionary].
	- parameter request:  NSMutableURLRequest returned from .requestFactory
	- parameter completion: NetterDataResult
	- returns: (AnyObject?, String?)
	*/
	public static func getJSONResponseFromRequest(request: NSMutableURLRequest, completion: NetterDataResult -> Void) {
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithRequest(request) {
			data, response, error in
			if let error = error {
				completion(NetterDataResult.Failure(error.localizedDescription))
				return }
			guard let httpResponse = response as? NSHTTPURLResponse else {
				debugPrint("Failed to cast httpResponse as NSHTTPURLResponse")
				return }
			guard let data = data else {
				debugPrint("No data returned")
				return }
			
			if httpResponse.statusCode == NetterStatusCodes.Success {
				do {
					let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
					completion(NetterDataResult.Success(json))
				} catch {
					completion(NetterDataResult.Failure("Failed to retrieve JSON response"))
				}
			}
		}
		
		task.resume()
	}
	
}