import SwiftUI

struct MainTabView: View {
    @State private var leadManager = LeadManager()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
            
            LeadListView()
                .tabItem {
                    Label("线索", systemImage: "list.bullet.rectangle.portrait.fill")
                }
            
            LeadAggregationView()
                .tabItem {
                    Label("线索聚合", systemImage: "folder.fill")
                }
                .environment(leadManager)
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
        }
        .tint(.blue)
        .environment(leadManager)
    }
}

#Preview {
    MainTabView()
        .environment(DataStore())
}