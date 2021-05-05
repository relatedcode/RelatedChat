//
// Copyright (c) 2021 Related Code - https://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import GraphQLite

//-----------------------------------------------------------------------------------------------------------------------------------------------
var gqldb: GQLDatabase!
var gqlserver: GQLServer!

//-----------------------------------------------------------------------------------------------------------------------------------------------
class GraphQLite: NSObject {

	//-------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: GraphQLite = {
		let instance = GraphQLite()
		return instance
	} ()

	//-------------------------------------------------------------------------------------------------------------------------------------------
	class func setup() {

		_ = shared
	}

	//-------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		GQLNetwork.setup()

		gqldb = GQLDatabase()

		let key = "da2-af2vcmhckjelri4jjxuxklv67i"
		let link = "https://34rle7userfklfhpcqashdlqua.appsync-api.us-east-2.amazonaws.com/graphql"
		gqlserver = GQLServer(AppSync: link, key: key)
	}
}
