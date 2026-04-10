import Foundation

// MARK: - PulseClientError

enum PulseClientError: LocalizedError {
    case invalidURL
    case httpError(Int)
    case decodingFailed(Error)
    case networkFailure(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid endpoint URL."
        case .httpError(let code):
            return "Server returned HTTP \(code)."
        case .decodingFailed(let err):
            return "Failed to decode response: \(err.localizedDescription)"
        case .networkFailure(let err):
            return "Network error: \(err.localizedDescription)"
        }
    }
}

// MARK: - PulseClientProtocol

protocol PulseClientProtocol {
    func fetchVelocityTrends() async throws -> PulseFeedResponse
}

// MARK: - PulseClient

final class PulseClient: PulseClientProtocol {

    // In production this points to the Cloudflare Worker relay.
    // Replaced by the bundled mock JSON when `useMockData` is true.
    static let relayEndpoint = "https://pulse-relay.workers.dev/api/v1/trends"

    private let session: URLSession
    private let decoder: JSONDecoder
    private let useMockData: Bool

    init(
        session: URLSession = .shared,
        useMockData: Bool = true          // set false when connecting to live relay
    ) {
        self.session = session
        self.useMockData = useMockData

        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        self.decoder = dec
    }

    // MARK: - Public API

    /// Fetches velocity trends from the relay (or bundled mock data).
    func fetchVelocityTrends() async throws -> PulseFeedResponse {
        if useMockData {
            return try loadMockData()
        }
        return try await fetchRemote()
    }

    // MARK: - Private Helpers

    private func fetchRemote() async throws -> PulseFeedResponse {
        guard let url = URL(string: Self.relayEndpoint) else {
            throw PulseClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw PulseClientError.networkFailure(error)
        }

        if let httpResp = response as? HTTPURLResponse,
           !(200..<300).contains(httpResp.statusCode) {
            throw PulseClientError.httpError(httpResp.statusCode)
        }

        do {
            return try decoder.decode(PulseFeedResponse.self, from: data)
        } catch {
            throw PulseClientError.decodingFailed(error)
        }
    }

    private func loadMockData() throws -> PulseFeedResponse {
        guard let url = Bundle.main.url(
            forResource: "mock_velocity_trends",
            withExtension: "json"
        ) else {
            throw PulseClientError.invalidURL
        }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(PulseFeedResponse.self, from: data)
        } catch {
            throw PulseClientError.decodingFailed(error)
        }
    }
}

// MARK: - WebhookClient

final class WebhookClient {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Sends a pinned trend JSON payload to the user-configured webhook URL.
    func send(trend: VelocityTrend, to webhookURL: URL) async throws {
        let payload = WebhookPayload(trend: trend)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(payload)

        var request = URLRequest(url: webhookURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.timeoutInterval = 10

        let (_, response) = try await session.data(for: request)
        if let httpResp = response as? HTTPURLResponse,
           !(200..<300).contains(httpResp.statusCode) {
            throw PulseClientError.httpError(httpResp.statusCode)
        }
    }
}

// MARK: - WebhookPayload

private struct WebhookPayload: Encodable {
    let trendID: String
    let niche: String
    let headline: String
    let velocityScore: Double
    let isBreaking: Bool
    let sourceURL: String
    let sentAt: Date

    init(trend: VelocityTrend) {
        self.trendID      = trend.id
        self.niche        = trend.niche.rawValue
        self.headline     = trend.headline
        self.velocityScore = trend.velocityScore
        self.isBreaking   = trend.isBreaking
        self.sourceURL    = trend.sourceURL
        self.sentAt       = Date()
    }

    enum CodingKeys: String, CodingKey {
        case trendID      = "trend_id"
        case niche, headline
        case velocityScore = "velocity_score"
        case isBreaking    = "is_breaking"
        case sourceURL     = "source_url"
        case sentAt        = "sent_at"
    }
}
