class PagesController < ApplicationController
  def welcome
  end

  def package_pricing
  end

  def a_la_carte_pricing
  end

  def faqs
  end

  def about_us
  end

  def contact_us
  end

  def book_incubator
  end

  def why
  end

  def books
    @books = [
      { height: 4, title: 'Love at First Click', image: 'books/love-at-first-click.jpg', caption: 'My whole life changed on September 10, when he accepted my friend request on Facebook, a popular social networking site. His name was Noah Knight, and this is our story.', url: 'http://www.amazon.com/Love-First-Click-Mona-Lin/dp/0990591719' },
      { height: 4, image: 'books/persecution-complex.jpg', title: 'Persecution Complex', caption: 'Jason Wiedel cuts through the fog around this issue and reveals the truth behind the persecution complex: we’re not being persecuted, we’re losing privilege. Wiedel’s insights and exploration in to this concept help us to see why the loss of privilege is actually a blessing and how the false narrative of persecution is damaging Christianity and our witness to the world.', url: 'http://jasonwiedel.com/persecution-complex/' },
      { height: 5, image: 'books/did-god-invent-the-internet.jpg', title: 'Did God Invent the Internet?', caption: 'The book presents a vision as to how technology is changing the human race, and addresses the question; will we be happy with the ultimate outcome?', url: 'http://www.crowdscribed.com/scott-klososky/' },
      { height: 4, image: 'books/rewilding-the-way.png', title: 'REWiLDiNG THE WAY', caption: 'When did we become so tame? How has “the good life” come to mean addiction to screens and status, fossil fuels and financial fitness? Trek along with wilderness guide Todd Wynward as he “rewilds” the Jesus Way.', url: 'http://crowdscribed.com/mennomedia-hp/rewilding-the-way/' },
      { height: 3, image: 'books/building-a-discipling-culture.png', title: 'Building a Discipling Culture', caption: 'We have a discipleship problem. If we make disciples like Jesus made them, well never have a problem finding leaders or seeing new people coming to faith.', url: 'http://crowdscribed.com/3dm-publishing/buildingadisciplingculture/' },
      { height: 2, title: 'Confronting the Predicament Belief', image: 'books/confronting-the-predicament-of-belief.jpg', caption: 'What happens when discussions of the deepest issues—God and science, faith and doubt, suffering and evil, death and resurrection—are guided by the real-life challenges of believing and living in today’s world?', url: 'http://crowdscribed.com/clayton-knapp-walters-confronting-the-predicament-of-belief/confronting-the-predicament-of-belief/' },
      { height: nil, title: 'Covenant and Kingdom', image: 'books/covenant-and-kingdom.png', caption: 'How we can take the “Christian vices” inherent in our religion-such as pride, unquestioning certainty, and judgment- and transform them into “Christian virtues”- humility, faith, and mercy', url: 'http://crowdscribed.com/3dm-publishing/covenant-and-kingdom-2/' },
      { height: 4, image: 'books/post-christian.jpg', title: 'Post Christian', caption: 'How we can take the “Christian vices” inherent in our religion-such as pride, unquestioning certainty, and judgment- and transform them into “Christian virtues”- humility, faith, and mercy', url: 'http://crowdscribed.com/christianpiatt/' }
    ]
  end
end
