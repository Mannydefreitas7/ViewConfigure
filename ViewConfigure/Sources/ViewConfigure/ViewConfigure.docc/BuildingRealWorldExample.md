# Building a Real-World Example

Build a complete social media card component using ViewConfigure to demonstrate real-world usage patterns.

## Overview

In this tutorial, we'll build a complete social media card component that demonstrates ViewConfigure's capabilities in a real-world scenario. The card will include user interactions, state management, and sophisticated styling while following best practices.

Our social media card will feature:
- User avatar and profile information
- Post content with rich media support
- Interaction buttons (like, comment, share)
- Dynamic styling based on post state
- Analytics tracking
- Accessibility support

## Project Setup

First, let's define our data models:

```swift
import Foundation

struct User: Identifiable, Codable {
    let id: String
    let username: String
    let displayName: String
    let avatarURL: URL?
    let isVerified: Bool
}

struct SocialPost: Identifiable, Codable {
    let id: String
    let user: User
    let content: String
    let imageURL: URL?
    let createdAt: Date
    let likeCount: Int
    let commentCount: Int
    let shareCount: Int
    let isLiked: Bool
    let isBookmarked: Bool
}

enum PostInteraction {
    case like, unlike, comment, share, bookmark, unbookmark
}
```

## Creating Custom Stores

Let's create stores to manage our social media data and interactions:

```swift
import ViewConfigure
import Combine

@Register(.store)
class SocialFeedStore: Store {
    let id = UUID()
    
    @Published var posts: [SocialPost] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    required init() {}
    
    func loadPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Simulate API call
            try await Task.sleep(nanoseconds: 1_000_000_000)
            let fetchedPosts = try await APIService.shared.fetchPosts()
            
            await MainActor.run {
                self.posts = fetchedPosts
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func updatePost(_ post: SocialPost) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index] = post
        }
    }
}

@Register(.store)
class PostInteractionStore: Store {
    let id = UUID()
    
    @Published var interactionCounts: [String: InteractionCounts] = [:]
    @Published var userInteractions: [String: Set<PostInteraction>] = [:]
    
    struct InteractionCounts {
        var likes: Int
        var comments: Int
        var shares: Int
    }
    
    required init() {}
    
    func handleInteraction(_ interaction: PostInteraction, for postId: String) {
        var userPostInteractions = userInteractions[postId] ?? Set<PostInteraction>()
        var counts = interactionCounts[postId] ?? InteractionCounts(likes: 0, comments: 0, shares: 0)
        
        switch interaction {
        case .like:
            if !userPostInteractions.contains(.like) {
                userPostInteractions.insert(.like)
                counts.likes += 1
            }
        case .unlike:
            if userPostInteractions.contains(.like) {
                userPostInteractions.remove(.like)
                counts.likes = max(0, counts.likes - 1)
            }
        case .comment:
            // Handle comment interaction
            break
        case .share:
            if !userPostInteractions.contains(.share) {
                userPostInteractions.insert(.share)
                counts.shares += 1
            }
        case .bookmark, .unbookmark:
            if interaction == .bookmark {
                userPostInteractions.insert(.bookmark)
            } else {
                userPostInteractions.remove(.bookmark)
            }
        }
        
        userInteractions[postId] = userPostInteractions
        interactionCounts[postId] = counts
        
        // Track analytics
        AnalyticsService.shared.track(interaction, for: postId)
    }
    
    func isLiked(_ postId: String) -> Bool {
        userInteractions[postId]?.contains(.like) ?? false
    }
    
    func isBookmarked(_ postId: String) -> Bool {
        userInteractions[postId]?.contains(.bookmark) ?? false
    }
    
    func getLikeCount(for postId: String) -> Int {
        interactionCounts[postId]?.likes ?? 0
    }
}

@Register(.store)
class AnalyticsStore: Store {
    let id = UUID()
    
    @Published var events: [AnalyticsEvent] = []
    
    struct AnalyticsEvent {
        let type: String
        let parameters: [String: Any]
        let timestamp: Date
    }
    
    required init() {}
    
    func trackEvent(_ type: String, parameters: [String: Any] = [:]) {
        let event = AnalyticsEvent(
            type: type,
            parameters: parameters,
            timestamp: Date()
        )
        events.append(event)
        
        // Send to analytics service
        AnalyticsService.shared.track(event)
    }
}
```

## Creating Custom Styles

Now let's create sophisticated styles for our social media card:

```swift
@Register(.style)
struct SocialCardStyle: Style {
    let cornerRadius: CGFloat
    let shadowIntensity: Double
    
    init(cornerRadius: CGFloat = 16, shadowIntensity: Double = 0.1) {
        self.cornerRadius = cornerRadius
        self.shadowIntensity = shadowIntensity
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: .black.opacity(shadowIntensity),
                radius: 8,
                x: 0,
                y: 4
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.separator, lineWidth: 0.5)
            )
    }
}

@Register(.style)
struct InteractionButtonStyle: Style {
    let isActive: Bool
    let activeColor: Color
    
    init(isActive: Bool = false, activeColor: Color = .blue) {
        self.isActive = isActive
        self.activeColor = activeColor
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isActive ? activeColor.opacity(0.1) : Color.clear)
            )
            .foregroundColor(isActive ? activeColor : .secondary)
            .scaleEffect(isActive ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isActive)
    }
}

@Register(.style)
struct UserAvatarStyle: Style {
    let size: CGFloat
    let showVerificationBadge: Bool
    
    init(size: CGFloat = 40, showVerificationBadge: Bool = false) {
        self.size = size
        self.showVerificationBadge = showVerificationBadge
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Group {
                    if showVerificationBadge {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                            .background(Circle().fill(.white))
                            .offset(x: size * 0.3, y: size * 0.3)
                    }
                }
            )
    }
}

@Register(.style)
struct AnimatedHeartStyle: Style {
    let isLiked: Bool
    let size: CGFloat
    
    init(isLiked: Bool, size: CGFloat = 20) {
        self.isLiked = isLiked
        self.size = size
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .font(.system(size: size, weight: .medium))
            .foregroundColor(isLiked ? .red : .secondary)
            .scaleEffect(isLiked ? 1.2 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isLiked)
    }
}
```

## Creating Custom Listeners

Let's create interactive listeners for our social media functionality:

```swift
@Register(.listener)
struct PostInteractionListener: Listener {
    let postId: String
    let interaction: PostInteraction
    let onInteraction: (PostInteraction, String) -> Void
    let hapticFeedback: Bool
    
    init(
        postId: String,
        interaction: PostInteraction,
        hapticFeedback: Bool = true,
        onInteraction: @escaping (PostInteraction, String) -> Void
    ) {
        self.postId = postId
        self.interaction = interaction
        self.onInteraction = onInteraction
        self.hapticFeedback = hapticFeedback
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .onTapGesture {
                if hapticFeedback {
                    #if os(iOS)
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    #endif
                }
                
                onInteraction(interaction, postId)
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint(accessibilityHint)
    }
    
    private var accessibilityLabel: String {
        switch interaction {
        case .like: return "Like post"
        case .unlike: return "Unlike post"
        case .comment: return "Comment on post"
        case .share: return "Share post"
        case .bookmark: return "Bookmark post"
        case .unbookmark: return "Remove bookmark"
        }
    }
    
    private var accessibilityHint: String {
        "Double tap to \(accessibilityLabel.lowercased())"
    }
}

@Register(.listener)
struct LongPressContextMenuListener: Listener {
    let postId: String
    let onShowMenu: (String) -> Void
    
    init(postId: String, onShowMenu: @escaping (String) -> Void) {
        self.postId = postId
        self.onShowMenu = onShowMenu
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .onLongPressGesture {
                #if os(iOS)
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                #endif
                onShowMenu(postId)
            }
    }
}

@Register(.listener)
struct VisibilityTrackingListener: Listener {
    let postId: String
    let onVisible: (String) -> Void
    let onHidden: (String) -> Void
    
    init(
        postId: String,
        onVisible: @escaping (String) -> Void,
        onHidden: @escaping (String) -> Void
    ) {
        self.postId = postId
        self.onVisible = onVisible
        self.onHidden = onHidden
    }
    
    func apply<Content: View>(to content: Content) -> some View {
        content
            .onAppear {
                onVisible(postId)
            }
            .onDisappear {
                onHidden(postId)
            }
    }
}
```

## Building the Social Media Card

Now let's combine everything into our social media card component:

```swift
struct SocialMediaCard: View {
    let post: SocialPost
    
    @Environment(PostInteractionStore.self) private var interactionStore
    @Environment(AnalyticsStore.self) private var analyticsStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User header
            userHeader
            
            // Post content
            postContent
            
            // Post image (if available)
            if let imageURL = post.imageURL {
                postImage(url: imageURL)
            }
            
            // Interaction buttons
            interactionButtons
        }
        .configured {
            style(SocialCardStyle())
            style(PaddingStyle(length: 16))
            listener(LongPressContextMenuListener(postId: post.id) { postId in
                showContextMenu(for: postId)
            })
            listener(VisibilityTrackingListener(
                postId: post.id,
                onVisible: { postId in
                    analyticsStore.trackEvent("post_viewed", parameters: ["post_id": postId])
                },
                onHidden: { postId in
                    analyticsStore.trackEvent("post_hidden", parameters: ["post_id": postId])
                }
            ))
        }
    }
    
    private var userHeader: some View {
        HStack {
            AsyncImage(url: post.user.avatarURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(.gray.opacity(0.3))
            }
            .configured {
                style(UserAvatarStyle(
                    size: 40,
                    showVerificationBadge: post.user.isVerified
                ))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(post.user.displayName)
                        .font(.headline)
                    
                    if post.user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }
                
                Text("@\(post.user.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatTimeAgo(post.createdAt))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var postContent: some View {
        Text(post.content)
            .font(.body)
            .multilineTextAlignment(.leading)
            .configured {
                style(PaddingStyle(edges: .vertical, length: 4))
            }
    }
    
    private func postImage(url: URL) -> some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray.opacity(0.3))
                .frame(height: 200)
        }
        .configured {
            style(CornerRadiusStyle(radius: 12))
            style(ClipShapeStyle(shape: RoundedRectangle(cornerRadius: 12)))
        }
    }
    
    private var interactionButtons: some View {
        HStack(spacing: 24) {
            likeButton
            commentButton
            shareButton
            
            Spacer()
            
            bookmarkButton
        }
        .configured {
            style(PaddingStyle(edges: .top, length: 8))
        }
    }
    
    private var likeButton: some View {
        HStack(spacing: 4) {
            Image(systemName: interactionStore.isLiked(post.id) ? "heart.fill" : "heart")
                .configured {
                    style(AnimatedHeartStyle(isLiked: interactionStore.isLiked(post.id)))
                }
            
            if interactionStore.getLikeCount(for: post.id) > 0 {
                Text("\(interactionStore.getLikeCount(for: post.id))")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .configured {
            style(InteractionButtonStyle(
                isActive: interactionStore.isLiked(post.id),
                activeColor: .red
            ))
            listener(PostInteractionListener(
                postId: post.id,
                interaction: interactionStore.isLiked(post.id) ? .unlike : .like
            ) { interaction, postId in
                interactionStore.handleInteraction(interaction, for: postId)
            })
        }
    }
    
    private var commentButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "message")
            
            if post.commentCount > 0 {
                Text("\(post.commentCount)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .configured {
            style(InteractionButtonStyle())
            listener(PostInteractionListener(
                postId: post.id,
                interaction: .comment
            ) { interaction, postId in
                showComments(for: postId)
            })
        }
    }
    
    private var shareButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "square.and.arrow.up")
            
            if post.shareCount > 0 {
                Text("\(post.shareCount)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .configured {
            style(InteractionButtonStyle())
            listener(PostInteractionListener(
                postId: post.id,
                interaction: .share
            ) { interaction, postId in
                sharePost(postId)
            })
        }
    }
    
    private var bookmarkButton: some View {
        Image(systemName: interactionStore.isBookmarked(post.id) ? "bookmark.fill" : "bookmark")
            .configured {
                style(InteractionButtonStyle(
                    isActive: interactionStore.isBookmarked(post.id),
                    activeColor: .orange
                ))
                listener(PostInteractionListener(
                    postId: post.id,
                    interaction: interactionStore.isBookmarked(post.id) ? .unbookmark : .bookmark
                ) { interaction, postId in
                    interactionStore.handleInteraction(interaction, for: postId)
                })
            }
    }
    
    // MARK: - Helper Methods
    
    private func formatTimeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func showContextMenu(for postId: String) {
        // Show context menu implementation
        analyticsStore.trackEvent("context_menu_shown", parameters: ["post_id": postId])
    }
    
    private func showComments(for postId: String) {
        // Show comments implementation
        analyticsStore.trackEvent("comments_opened", parameters: ["post_id": postId])
    }
    
    private func sharePost(_ postId: String) {
        // Share post implementation
        #if os(iOS)
        let activityViewController = UIActivityViewController(
            activityItems: ["Check out this post!"],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
        #endif
        
        analyticsStore.trackEvent("post_shared", parameters: ["post_id": postId])
    }
}
```

## Creating the Feed View

Finally, let's create a feed view that uses our social media cards:

```swift
struct SocialFeedView: View {
    @State private var refreshTrigger = UUID()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(feedStore.posts) { post in
                        SocialMediaCard(post: post)
                            .configured {
                                listener(VisibilityTrackingListener(
                                    postId: post.id,
                                    onVisible: { _ in
                                        // Track post impression
                                    },
                                    onHidden: { _ in
                                        // Track post scroll past
                                    }
                                ))
                            }
                    }
                }
                .configured {
                    style(PaddingStyle(length: 16))
                }
            }
            .navigationTitle("Social Feed")
            .refreshable {
                await feedStore.loadPosts()
            }
        }
        .configured {
            store(SocialFeedStore())
            store(PostInteractionStore())
            store(AnalyticsStore())
        }
        .task {
            await feedStore.loadPosts()
        }
    }
    
    @Environment(SocialFeedStore.self) private var feedStore
}
```

## Usage in Your App

To use the social feed in your app:

```swift
@main
struct SocialApp: App {
    var body: some Scene {
        WindowGroup {
            SocialFeedView()
                .configured {
                    // Global stores
                    store(ThemeStore())
                    store(UserAuthenticationStore())
                    store(NetworkMonitoringStore())
                }
        }
    }
}
```

## Key Takeaways

This real-world example demonstrates several important ViewConfigure concepts:

1. **Separation of Concerns**: Each store handles a specific domain (feed data, interactions, analytics)
2. **Reusable Components**: Styles and listeners are designed to be reusable across different contexts  
3. **Progressive Enhancement**: Complex interactions are built up from simple, focused components
4. **State Management**: Multiple stores coordinate to provide comprehensive functionality
5. **Accessibility**: Proper accessibility labels and hints are included
6. **Performance**: Lazy loading and efficient state updates minimize performance impact
7. **Analytics Integration**: User interactions are automatically tracked for insights

This pattern scales well for larger applications and provides a solid foundation for building complex, interactive UI components with ViewConfigure.

## See Also

- <doc:BestPractices>
- <doc:CreatingCustomComponents> 
- <doc:Stores>
- <doc:Performance>
