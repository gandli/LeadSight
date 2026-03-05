import SwiftUI

struct MainTabView: View {
    @State private var caseManager = CaseManager()
    
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
            
            CaseListView()
                .tabItem {
                    Label("案件", systemImage: "folder.fill")
                }
                .environment(caseManager)
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
        }
        .tint(.blue)
        .environment(caseManager)
    }
}

#Preview {
    MainTabView()
        .environment(DataStore())
}
