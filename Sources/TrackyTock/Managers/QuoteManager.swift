import Foundation
import SwiftUI

/// Manages rotating daily motivational quotes with date-based daily progression, random manual refresh, and 255+ inspiring entries.
public class QuoteManager: ObservableObject {
    public static let shared = QuoteManager()
    
    private let userDefaults = UserDefaults.standard
    private let lastQuoteDateKey = "TrackyTock_LastQuoteDate"
    private let quoteIndexKey = "TrackyTock_CurrentQuoteIndex"
    
    @Published public var currentQuote: String = ""
    @Published public var author: String = ""
    @Published public var currentIndex: Int = 0
    
    // Comprehensive collection of 255 unique inspiring productivity & focus quotes
    public let quotes: [(quote: String, author: String)] = [
        // 1-50
        ("The secret of getting ahead is getting started.", "Mark Twain"),
        ("Don't watch the clock; do what it does. Keep going.", "Sam Levenson"),
        ("It always seems impossible until it's done.", "Nelson Mandela"),
        ("Focus on being productive instead of busy.", "Tim Ferriss"),
        ("Amateurs sit and wait for inspiration, the rest of us just get up and go to work.", "Stephen King"),
        ("Your time is limited, so don't waste it living someone else's life.", "Steve Jobs"),
        ("Simplicity boils down to two steps: Identify the essential. Eliminate the rest.", "Leo Babauta"),
        ("You don't have to see the whole staircase, just take the first step.", "Martin Luther King Jr."),
        ("Action is the foundational key to all success.", "Pablo Picasso"),
        ("Small deeds done are better than great deeds planned.", "Peter Marshall"),
        ("Start where you are. Use what you have. Do what you can.", "Arthur Ashe"),
        ("The way to get started is to quit talking and begin doing.", "Walt Disney"),
        ("Productivity is never an accident. It is always the result of a commitment to excellence.", "Paul J. Meyer"),
        ("Do the hard jobs first. The easy jobs will take care of themselves.", "Dale Carnegie"),
        ("Concentrate all your thoughts upon the work in hand. The sun's rays do not burn until brought to a focus.", "Alexander Graham Bell"),
        ("Efficiency is doing things right; effectiveness is doing the right things.", "Peter Drucker"),
        ("Ordinary people think merely of spending time, great people think of using it.", "Arthur Schopenhauer"),
        ("Until we can manage time, we can manage nothing else.", "Peter Drucker"),
        ("The key is not to prioritize what's on your schedule, but to schedule your priorities.", "Stephen Covey"),
        ("Done is better than perfect.", "Sheryl Sandberg"),
        ("Great things are done by a series of small things brought together.", "Vincent Van Gogh"),
        ("Continuous improvement is better than delayed perfection.", "Mark Twain"),
        ("Quality is not an act, it is a habit.", "Aristotle"),
        ("It is not enough to be busy. The question is: what are we busy about?", "Henry David Thoreau"),
        ("Lost time is never found again.", "Benjamin Franklin"),
        ("One reason so few of us achieve what we truly want is that we never direct our focus.", "Tony Robbins"),
        ("He who has a why to live can bear almost any how.", "Friedrich Nietzsche"),
        ("The most difficult thing is the decision to act, the rest is merely tenacity.", "Amelia Earhart"),
        ("Discipline is choosing between what you want now and what you want most.", "Abraham Lincoln"),
        ("You may delay, but time will not.", "Benjamin Franklin"),
        ("Deep work is the ability to focus without distraction on a cognitively demanding task.", "Cal Newport"),
        ("Energy, not time, is the fundamental currency of high performance.", "Jim Loehr"),
        ("The journey of a thousand miles begins with one step.", "Lao Tzu"),
        ("Don't let yesterday take up too much of today.", "Will Rogers"),
        ("Setting goals is the first step in turning the invisible into the visible.", "Tony Robbins"),
        ("Focus is a muscle. The more you practice, the stronger it gets.", "Anonymous"),
        ("You can do anything, but not everything.", "David Allen"),
        ("Motivation gets you going, but discipline keeps you growing.", "John C. Maxwell"),
        ("Take care of the minutes and the hours will take care of themselves.", "Lord Chesterfield"),
        ("Where focus goes, energy flows.", "Tony Robbins"),
        ("Either you run the day or the day runs you.", "Jim Rohn"),
        ("Never mistake motion for action.", "Ernest Hemingway"),
        ("A year from now you may wish you had started today.", "Karen Lamb"),
        ("Think of many things; do one.", "Portuguese Proverb"),
        ("The future depends on what you do today.", "Mahatma Gandhi"),
        ("Success is the sum of small efforts, repeated day in and day out.", "Robert Collier"),
        ("Energy is contagious, focus is magnetic.", "Anonymous"),
        ("Consistency is the true foundation of trust in oneself.", "Anonymous"),
        ("Make each day your masterpiece.", "John Wooden"),
        ("Today's progress begins with today's focus.", "Tracky-Tock"),

        // 51-100
        ("You do not rise to the level of your goals. You fall to the level of your systems.", "James Clear"),
        ("We are what we repeatedly do. Excellence, then, is not an act, but a habit.", "Will Durant"),
        ("In the middle of difficulty lies opportunity.", "Albert Einstein"),
        ("It is not that we have a short time to live, but that we waste a lot of it.", "Seneca"),
        ("No pressure, no diamonds.", "Thomas Carlyle"),
        ("Mastering others is strength. Mastering yourself is true power.", "Lao Tzu"),
        ("If you spend too much time thinking about a thing, you'll never get it done.", "Bruce Lee"),
        ("Small disciplines repeated with consistency every day lead to great achievements.", "John C. Maxwell"),
        ("He who conquers himself is the mightiest warrior.", "Confucius"),
        ("Your habit of delaying what you should do is the greatest obstacle to your peace.", "Marcus Aurelius"),
        ("Do not wait to strike till the iron is hot; but make it hot by striking.", "William Butler Yeats"),
        ("A goal without a plan is just a wish.", "Antoine de Saint-Exupéry"),
        ("The successful warrior is the average man, with laser-like focus.", "Bruce Lee"),
        ("You miss 100% of the shots you don't take.", "Wayne Gretzky"),
        ("What gets measured gets managed.", "Peter Drucker"),
        ("Courage is resistance to fear, mastery of fear—not absence of fear.", "Mark Twain"),
        ("Nothing will work unless you do.", "Maya Angelou"),
        ("The scariest moment is always just before you start.", "Stephen King"),
        ("Concentration is the secret of strength in politics, in war, in trade, in all management of human affairs.", "Ralph Waldo Emerson"),
        ("The impediment to action advances action. What stands in the way becomes the way.", "Marcus Aurelius"),
        ("Success is not final, failure is not fatal: it is the courage to continue that counts.", "Winston Churchill"),
        ("To be disciplined is to follow in a good way, to be only governed by the truth.", "Jiddu Krishnamurti"),
        ("Rivers know this: there is no hurry. We shall get there some day.", "A.A. Milne"),
        ("Patience, persistence and perspiration make an unbeatable combination for success.", "Napoleon Hill"),
        ("Knowing is not enough; we must apply. Willing is not enough; we must do.", "Johann Wolfgang von Goethe"),
        ("The man who moves a mountain begins by carrying away small stones.", "Confucius"),
        ("He who has begun has half done. Dare to be wise; begin.", "Horace"),
        ("Don't count the days, make the days count.", "Muhammad Ali"),
        ("You don't need more time, you just need to decide.", "Seth Godin"),
        ("Simplicity is the ultimate sophistication.", "Leonardo da Vinci"),
        ("Focus means saying no to the hundred other good ideas.", "Steve Jobs"),
        ("The best time to plant a tree was 20 years ago. The second best time is now.", "Chinese Proverb"),
        ("Everything you've ever wanted is on the other side of fear.", "George Addair"),
        ("One today is worth two tomorrows.", "Benjamin Franklin"),
        ("Light tomorrow with today!", "Elizabeth Barrett Browning"),
        ("Little by little, one walks far.", "Peruvian Proverb"),
        ("Doubt kills more dreams than failure ever will.", "Suzy Kassem"),
        ("A problem is a chance for you to do your best.", "Duke Ellington"),
        ("Be not afraid of going slowly, be afraid only of standing still.", "Chinese Proverb"),
        ("An ounce of action is worth a ton of theory.", "Friedrich Engels"),
        ("Do what you can, with what you have, where you are.", "Theodore Roosevelt"),
        ("The price of excellence is discipline. The cost of mediocrity is disappointment.", "William Arthur Ward"),
        ("I never dreamed about success. I worked for it.", "Estée Lauder"),
        ("Opportunities don't happen. You create them.", "Chris Grosser"),
        ("Genius is one percent inspiration and ninety-nine percent perspiration.", "Thomas Edison"),
        ("Life is 10% what happens to you and 90% how you react to it.", "Charles R. Swindoll"),
        ("The only limit to our realization of tomorrow will be our doubts of today.", "Franklin D. Roosevelt"),
        ("Adopt the pace of nature: her secret is patience.", "Ralph Waldo Emerson"),
        ("Act as if what you do makes a difference. It does.", "William James"),
        ("Begin anywhere.", "John Cage"),

        // 101-150
        ("First say to yourself what you would be; and then do what you have to do.", "Epictetus"),
        ("Perseverance is not a long race; it is many short races one after the other.", "Walter Elliot"),
        ("Action expresses priorities.", "Mahatma Gandhi"),
        ("Great minds have purposes, others have wishes.", "Washington Irving"),
        ("Well begun is half done.", "Aristotle"),
        ("It does not matter how slowly you go as long as you do not stop.", "Confucius"),
        ("There is no substitute for hard work.", "Thomas Edison"),
        ("Nothing is particularly hard if you divide it into small jobs.", "Henry Ford"),
        ("The tragedy in life does not lie in not reaching your goal. The tragedy lies in having no goal to reach.", "Benjamin E. Mays"),
        ("If you want to achieve greatness stop asking for permission.", "Anonymous"),
        ("Things do not happen. Things are made to happen.", "John F. Kennedy"),
        ("You will never plow a field if you only turn it over in your mind.", "Irish Proverb"),
        ("Champions keep playing until they get it right.", "Billie Jean King"),
        ("The greatest remedy for anger is delay.", "Seneca"),
        ("The creation of a thousand forests is in one acorn.", "Ralph Waldo Emerson"),
        ("Do one thing every day that scares you.", "Eleanor Roosevelt"),
        ("If there is no struggle, there is no progress.", "Frederick Douglass"),
        ("You must do the thing you think you cannot do.", "Eleanor Roosevelt"),
        ("The mind is everything. What you think you become.", "Buddha"),
        ("Inspiration exists, but it has to find you working.", "Pablo Picasso"),
        ("The harder the conflict, the more glorious the triumph.", "Thomas Paine"),
        ("I attribute my success to this: I never gave or took any excuse.", "Florence Nightingale"),
        ("Work hard in silence, let your success be your noise.", "Frank Ocean"),
        ("Dream big and dare to fail.", "Norman Vaughan"),
        ("Fall seven times, stand up eight.", "Japanese Proverb"),
        ("The only way to achieve the impossible is to believe it is possible.", "Charles Kingsleigh"),
        ("What we achieve inwardly will change outer reality.", "Plutarch"),
        ("No one is to blame for your future situation but yourself.", "Jim Rohn"),
        ("Do not let what you cannot do interfere with what you can do.", "John Wooden"),
        ("The distance between dreams and reality is called action.", "Anonymous"),
        ("Do not wait; the time will never be 'just right.'", "Napoleon Hill"),
        ("Everything has beauty, but not everyone sees it.", "Confucius"),
        ("I find that the harder I work, the more luck I seem to have.", "Thomas Jefferson"),
        ("Energy and persistence conquer all things.", "Benjamin Franklin"),
        ("A diamond is a chunk of coal that did well under pressure.", "Henry Kissinger"),
        ("A champion is defined not by their wins but by how they can recover when they fall.", "Serena Williams"),
        ("Perseverance is failing 19 times and succeeding the 20th.", "Julie Andrews"),
        ("Discipline is the bridge between goals and accomplishment.", "Jim Rohn"),
        ("Nothing diminishes anxiety faster than action.", "Walter Anderson"),
        ("Life shrinks or expands in proportion to one's courage.", "Anaïs Nin"),
        ("If you're going through hell, keep going.", "Winston Churchill"),
        ("Either write something worth reading or do something worth writing.", "Benjamin Franklin"),
        ("Live as if you were to die tomorrow. Learn as if you were to live forever.", "Mahatma Gandhi"),
        ("Every moment is a fresh beginning.", "T.S. Eliot"),
        ("Never give up on a dream just because of the time it will take to accomplish it. The time will pass anyway.", "Earl Nightingale"),
        ("He that can have patience can have what he will.", "Benjamin Franklin"),
        ("You cannot find peace by avoiding life.", "Virginia Woolf"),
        ("The superior man is modest in his speech, but exceeds in his actions.", "Confucius"),
        ("Step by step and the thing is done.", "Charles Atlas"),
        ("Focus is not about doing less; it is about doing what matters most.", "Anonymous"),

        // 151-200
        ("Self-reverence, self-knowledge, self-control; these three alone lead life to sovereign power.", "Alfred Lord Tennyson"),
        ("The difference between a successful person and others is not a lack of strength, not a lack of knowledge, but rather a lack of will.", "Vince Lombardi"),
        ("What lies behind us and what lies before us are tiny matters compared to what lies within us.", "Ralph Waldo Emerson"),
        ("Look well to this day, for it is life, the very life of life.", "Kalidasa"),
        ("Our greatest glory is not in never falling, but in rising every time we fall.", "Confucius"),
        ("The soul should always stand ajar, ready to welcome the ecstatic experience.", "Emily Dickinson"),
        ("Don't be pushed around by the fears in your mind. Be led by the dreams in your heart.", "Roy T. Bennett"),
        ("Only those who dare to fail greatly can ever achieve greatly.", "Robert F. Kennedy"),
        ("Be curious, not judgmental.", "Walt Whitman"),
        ("To know what you know and what you do not know, that is true knowledge.", "Confucius"),
        ("Courage doesn't always roar. Sometimes courage is the quiet voice at the end of the day saying, 'I will try again tomorrow.'", "Mary Anne Radmacher"),
        ("What we fear doing most is usually what we most need to do.", "Tim Ferriss"),
        ("It's not what happens to you, but how you react to it that matters.", "Epictetus"),
        ("The unexamined life is not worth living.", "Socrates"),
        ("Character is destiny.", "Heraclitus"),
        ("Success usually comes to those who are too busy to be looking for it.", "Henry David Thoreau"),
        ("To thrive in life you need three bones: a wishbone, a backbone, and a funny bone.", "Reba McEntire"),
        ("Turn your wounds into wisdom.", "Oprah Winfrey"),
        ("Hard work beats talent when talent fails to work hard.", "Kevin Durant"),
        ("The only impossible journey is the one you never begin.", "Tony Robbins"),
        ("The standard you walk past is the standard you accept.", "David Morrison"),
        ("Success is liking yourself, liking what you do, and liking how you do it.", "Maya Angelou"),
        ("Do what you love and the necessary resources will follow.", "Peter McWilliams"),
        ("It is during our darkest moments that we must focus to see the light.", "Aristotle"),
        ("You have power over your mind - not outside events. Realize this, and you will find strength.", "Marcus Aurelius"),
        ("The secret of discipline is motivation. When a man is sufficiently motivated, discipline will take care of itself.", "Alexander Paterson"),
        ("Clarity precedes mastery.", "Robin Sharma"),
        ("A tiny drop of water hollows out the stone, not by force, but by falling often.", "Lucretius"),
        ("One step at a time is all it takes to get you there.", "Emily Dickinson"),
        ("Waste no more time arguing about what a good man should be. Be one.", "Marcus Aurelius"),
        ("Do not let the behavior of others destroy your inner peace.", "Dalai Lama"),
        ("We generate fears while we sit. We overcome them by action.", "Dr. Henry Link"),
        ("If you set your goals ridiculously high and it's a failure, you will fail above everyone else's success.", "James Cameron"),
        ("No discipline seems pleasant at the time, but later on it produces a harvest of peace and righteousness.", "Hebrews"),
        ("The purpose of life is a life of purpose.", "Robert Byrne"),
        ("The more you know, the more you realize you know nothing.", "Socrates"),
        ("Everything is hard before it is easy.", "Johann Wolfgang von Goethe"),
        ("Patience is bitter, but its fruit is sweet.", "Jean-Jacques Rousseau"),
        ("Don't worry about failures, worry about the chances you miss when you don't even try.", "Jack Canfield"),
        ("Great works are performed not by strength but by perseverance.", "Samuel Johnson"),
        ("The greatest glory in living lies not in never falling, but in rising every time we fall.", "Nelson Mandela"),
        ("Never let the fear of striking out keep you from playing the game.", "Babe Ruth"),
        ("There are no shortcuts to any place worth going.", "Beverly Sills"),
        ("I will prepare and some day my chance will come.", "Abraham Lincoln"),
        ("Simplicity is prerequisite for reliability.", "Edsger W. Dijkstra"),
        ("You are what you do, not what you say you'll do.", "Carl Jung"),
        ("A smooth sea never made a skilled sailor.", "Franklin D. Roosevelt"),
        ("Small opportunities are often the beginning of great enterprises.", "Demosthenes"),
        ("Believe you can and you're halfway there.", "Theodore Roosevelt"),
        ("Act without expectation.", "Lao Tzu"),

        // 201-255
        ("Look up at the stars and not down at your feet. Try to make sense of what you see.", "Stephen Hawking"),
        ("Wisdom begins in wonder.", "Socrates"),
        ("Be the change that you wish to see in the world.", "Mahatma Gandhi"),
        ("Nothing in life is to be feared, it is only to be understood. Now is the time to understand more.", "Marie Curie"),
        ("In three words I can sum up everything I've learned about life: it goes on.", "Robert Frost"),
        ("The true sign of intelligence is not knowledge but imagination.", "Albert Einstein"),
        ("If you cannot do great things, do small things in a great way.", "Napoleon Hill"),
        ("Happiness depends upon ourselves.", "Aristotle"),
        ("We must become the change we want to see.", "Mahatma Gandhi"),
        ("Silence is a source of great strength.", "Lao Tzu"),
        ("The power of imagination makes us infinite.", "John Muir"),
        ("Keep your face always toward the sunshine—and shadows will fall behind you.", "Walt Whitman"),
        ("Peace comes from within. Do not seek it without.", "Buddha"),
        ("There is nothing permanent except change.", "Heraclitus"),
        ("To improve is to change; to be perfect is to change often.", "Winston Churchill"),
        ("An unexamined life is a lost opportunity.", "Plato"),
        ("Work is love made visible.", "Khalil Gibran"),
        ("Perfection is not attainable, but if we chase perfection we can catch excellence.", "Vince Lombardi"),
        ("The only true wisdom is in knowing you know nothing.", "Socrates"),
        ("He who knows others is wise; he who knows himself is enlightened.", "Lao Tzu"),
        ("Dwell on the beauty of life. Watch the stars, and see yourself running with them.", "Marcus Aurelius"),
        ("Knowing yourself is the beginning of all wisdom.", "Aristotle"),
        ("Everything has a beginning and an ending. Embrace both.", "Anonymous"),
        ("Quiet the mind, and the soul will speak.", "Ma Jaya Sati Bhagavati"),
        ("To live is the rarest thing in the world. Most people exist, that is all.", "Oscar Wilde"),
        ("Out of clutter, find simplicity.", "Albert Einstein"),
        ("Your time is now. Stop waiting.", "Anonymous"),
        ("In nature, nothing is rushed, yet everything is accomplished.", "Lao Tzu"),
        ("The sun itself sees not till heaven clears.", "William Shakespeare"),
        ("Kind words can be short and easy to speak, but their echoes are truly endless.", "Mother Teresa"),
        ("The roots of education are bitter, but the fruit is sweet.", "Aristotle"),
        ("Fortune favors the bold.", "Virgil"),
        ("A quiet mind can hear intuition above all fear.", "Anonymous"),
        ("Study the past if you would define the future.", "Confucius"),
        ("Give me six hours to chop down a tree and I will spend the first four sharpening the axe.", "Abraham Lincoln"),
        ("The best preparation for tomorrow is doing your best today.", "H. Jackson Brown Jr."),
        ("Keep your eyes on the stars, and your feet on the ground.", "Theodore Roosevelt"),
        ("Simplicity is about subtracting the obvious and adding the meaningful.", "John Maeda"),
        ("Courage is found in unlikely places.", "J.R.R. Tolkien"),
        ("The energy of the mind is the essence of life.", "Aristotle"),
        ("Little moments make big memories.", "Anonymous"),
        ("Nothing is impossible to a willing heart.", "John Heywood"),
        ("The art of being wise is the art of knowing what to overlook.", "William James"),
        ("Small daily improvements over time lead to stunning results.", "Robin Sharma"),
        ("What you do today can improve all your tomorrows.", "Ralph Marston"),
        ("Every strike brings me closer to the next home run.", "Babe Ruth"),
        ("Begin with the end in mind.", "Stephen Covey"),
        ("To know yourself, think for yourself.", "Socrates"),
        ("He who has courage and faith will never perish in misery.", "Anne Frank"),
        ("Live each day as if life had just begun.", "Johann Wolfgang von Goethe"),
        ("The true secret of happiness lies in taking a genuine interest in all the details of daily life.", "William Morris"),
        ("Do not let the noise of others' opinions drown out your own inner voice.", "Steve Jobs"),
        ("Mastery is not a destination, but a continuous devotion to the craft.", "Tracky-Tock"),
        ("Focus today, conquer tomorrow.", "Tracky-Tock"),
        ("Consistency turns ambition into achievement.", "Tracky-Tock")
    ]
    
    public init() {
        loadDailyQuote()
    }
    
    /// Loads or advances the quote based on whether today is a new calendar day
    public func loadDailyQuote() {
        let savedIndex = userDefaults.integer(forKey: quoteIndexKey)
        let lastDate = userDefaults.object(forKey: lastQuoteDateKey) as? Date
        
        let targetIndex: Int
        if let last = lastDate, Calendar.current.isDateInToday(last) {
            // Same day: keep current saved index
            targetIndex = savedIndex % quotes.count
        } else {
            // New day or first launch: advance index
            targetIndex = (savedIndex + 1) % quotes.count
            userDefaults.set(Date(), forKey: lastQuoteDateKey)
            userDefaults.set(targetIndex, forKey: quoteIndexKey)
        }
        
        self.currentIndex = targetIndex
        self.currentQuote = quotes[targetIndex].quote
        self.author = quotes[targetIndex].author
    }
    
    /// Manually cycles to a random fresh quote in the collection
    public func cycleNextQuote() {
        withAnimation(.easeInOut(duration: 0.25)) {
            var nextIndex = Int.random(in: 0..<quotes.count)
            if nextIndex == currentIndex {
                nextIndex = (currentIndex + 1) % quotes.count
            }
            self.currentIndex = nextIndex
            self.currentQuote = quotes[nextIndex].quote
            self.author = quotes[nextIndex].author
            
            userDefaults.set(nextIndex, forKey: quoteIndexKey)
            userDefaults.set(Date(), forKey: lastQuoteDateKey)
        }
    }
}
