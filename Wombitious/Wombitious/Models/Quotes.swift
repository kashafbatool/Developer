//
//  Quotes.swift
//  Wombitious
//

import Foundation

enum Quotes {
    static func forLevel(_ level: Int) -> [String] {
        switch level {
        case 1: return struggling
        case 2: return low
        case 3: return okay
        case 4: return good
        case 5: return amazing
        default: return okay
        }
    }

    // Level 1 – Struggling 😔
    // Gentle, resilience, you're not alone
    static let struggling: [String] = [
        "Fall seven times and stand up eight. — Japanese Proverb",
        "When one door of happiness closes, another opens; but often we look so long at the closed door that we do not see the one that has been opened for us. — Helen Keller",
        "I've missed more than 9,000 shots in my career. I've failed over and over again in my life. And that is why I succeed. — Michael Jordan",
        "I didn't fail the test. I just found 100 ways to do it wrong. — Benjamin Franklin",
        "Remember that not getting what you want is sometimes a wonderful stroke of luck. — Dalai Lama",
        "The most common way people give up their power is by thinking they don't have any. — Alice Walker",
        "If you hear a voice within you say 'you cannot paint,' then by all means paint and that voice will be silenced. — Vincent Van Gogh",
        "Every strike brings me closer to the next home run. — Babe Ruth",
        "We can easily forgive a child who is afraid of the dark; the real tragedy of life is when men are afraid of the light. — Plato",
        "Challenges are what make life interesting and overcoming them is what makes life meaningful. — Joshua J. Marine",
        "A person who never made a mistake never tried anything new. — Albert Einstein",
        "The battles that count aren't the ones for gold medals. The struggles within yourself — that's where it's at. — Jesse Owens",
        "Everything has beauty, but not everyone can see. — Confucius",
        "Remember no one can make you feel inferior without your consent. — Eleanor Roosevelt",
        "When everything seems to be going against you, remember that the airplane takes off against the wind, not with it. — Henry Ford",
        "I have learned over the years that when one's mind is made up, this diminishes fear. — Rosa Parks",
        "If you look at what you have in life, you'll always have more. — Oprah Winfrey"
    ]

    // Level 2 – Low 😐
    // Small steps, keep going, one thing at a time
    static let low: [String] = [
        "It does not matter how slowly you go as long as you do not stop. — Confucius",
        "Start where you are. Use what you have. Do what you can. — Arthur Ashe",
        "Do what you can, where you are, with what you have. — Teddy Roosevelt",
        "The most difficult thing is the decision to act, the rest is merely tenacity. — Amelia Earhart",
        "Eighty percent of success is showing up. — Woody Allen",
        "If the wind will not serve, take to the oars. — Latin Proverb",
        "There are no traffic jams along the extra mile. — Roger Staubach",
        "You may be disappointed if you fail, but you are doomed if you don't try. — Beverly Sills",
        "You can't fall if you don't climb. But there's no joy in living your whole life on the ground. — Unknown",
        "The best time to plant a tree was 20 years ago. The second best time is now. — Chinese Proverb",
        "How wonderful it is that nobody need wait a single moment before starting to improve the world. — Anne Frank",
        "Too many of us are not living our dreams because we are living our fears. — Les Brown",
        "Life is 10% what happens to me and 90% of how I react to it. — Charles Swindoll",
        "People often say that motivation doesn't last. Well, neither does bathing. That's why we recommend it daily. — Zig Ziglar",
        "Teach thy tongue to say 'I do not know,' and thou shalt progress. — Maimonides",
        "Life is what happens to you while you're busy making other plans. — John Lennon"
    ]

    // Level 3 – Okay 🙂
    // Steady, purpose, mindset, identity
    static let okay: [String] = [
        "We become what we think about. — Earl Nightingale",
        "The mind is everything. What you think you become. — Buddha",
        "I am not a product of my circumstances. I am a product of my decisions. — Stephen Covey",
        "Whether you think you can or you think you can't, you're right. — Henry Ford",
        "The only person you are destined to become is the person you decide to be. — Ralph Waldo Emerson",
        "Believe you can and you're halfway there. — Theodore Roosevelt",
        "Happiness is not something readymade. It comes from your own actions. — Dalai Lama",
        "You become what you believe. — Oprah Winfrey",
        "Change your thoughts and you change your world. — Norman Vincent Peale",
        "When I let go of what I am, I become what I might be. — Lao Tzu",
        "Dreaming, after all, is a form of planning. — Gloria Steinem",
        "Life is not measured by the number of breaths we take, but by the moments that take our breath away. — Maya Angelou",
        "Certain things catch your eye, but pursue only those that capture the heart. — Ancient Indian Proverb",
        "Two roads diverged in a wood, and I took the one less traveled by, and that has made all the difference. — Robert Frost",
        "An unexamined life is not worth living. — Socrates",
        "If you do what you've always done, you'll get what you've always gotten. — Tony Robbins",
        "Life isn't about getting and having, it's about giving and being. — Kevin Kruse",
        "I've learned that people will forget what you said, people will forget what you did, but people will never forget how you made them feel. — Maya Angelou"
    ]

    // Level 4 – Good 😊
    // Ambition, momentum, reaching higher
    static let good: [String] = [
        "Whatever the mind of man can conceive and believe, it can achieve. — Napoleon Hill",
        "Either you run the day, or the day runs you. — Jim Rohn",
        "Go confidently in the direction of your dreams. Live the life you have imagined. — Henry David Thoreau",
        "Everything you've ever wanted is on the other side of fear. — George Addair",
        "Dream big and dare to fail. — Norman Vaughan",
        "It is never too late to be what you might have been. — George Eliot",
        "The question isn't who is going to let me; it's who is going to stop me. — Ayn Rand",
        "If you can dream it, you can achieve it. — Zig Ziglar",
        "Build your own dreams, or someone else will hire you to build theirs. — Farrah Gray",
        "Whatever you can do, or dream you can, begin it. Boldness has genius, power and magic in it. — Goethe",
        "Twenty years from now you will be more disappointed by the things you didn't do. Explore, Dream, Discover. — Mark Twain",
        "Limitations live only in our minds. But if we use our imaginations, our possibilities become limitless. — Jamie Paolinetti",
        "Life shrinks or expands in proportion to one's courage. — Anais Nin",
        "Knowing is not enough; we must apply. Being willing is not enough; we must do. — Leonardo da Vinci",
        "It's your place in the world; it's your life. Go on and do all you can with it. — Mae Jemison",
        "You can't use up creativity. The more you use, the more you have. — Maya Angelou",
        "Strive not to be a success, but rather to be of value. — Albert Einstein"
    ]

    // Level 5 – Amazing 🔥
    // Bold, fired up, go get it
    static let amazing: [String] = [
        "Life is about making an impact, not making an income. — Kevin Kruse",
        "I attribute my success to this: I never gave or took any excuse. — Florence Nightingale",
        "You miss 100% of the shots you don't take. — Wayne Gretzky",
        "Your time is limited, so don't waste it living someone else's life. — Steve Jobs",
        "The best revenge is massive success. — Frank Sinatra",
        "If you're offered a seat on a rocket ship, don't ask what seat! Just get on. — Sheryl Sandberg",
        "I would rather die of passion than of boredom. — Vincent van Gogh",
        "Our lives begin to end the day we become silent about things that matter. — Martin Luther King Jr.",
        "Either write something worth reading or do something worth writing. — Benjamin Franklin",
        "The only way to do great work is to love what you do. — Steve Jobs",
        "Nothing is impossible — the word itself says 'I'm possible!' — Audrey Hepburn",
        "You can never cross the ocean until you have the courage to lose sight of the shore. — Christopher Columbus",
        "Winning isn't everything, but wanting to win is. — Vince Lombardi",
        "When I stand before God at the end of my life, I would hope I could say: I used everything you gave me. — Erma Bombeck",
        "The person who says it cannot be done should not interrupt the person who is doing it. — Chinese Proverb",
        "It's not the years in your life that count. It's the life in your years. — Abraham Lincoln",
        "Definiteness of purpose is the starting point of all achievement. — W. Clement Stone"
    ]
}
