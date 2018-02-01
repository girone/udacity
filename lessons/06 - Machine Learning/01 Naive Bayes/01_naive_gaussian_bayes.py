import numpy as np 

X = np.array([[-1, -1], [-2, -1], [-3, -2], [1, 1], [2, 1], [3, 2]])
labels = np.array([[1, 1, 1, 2, 2, 2]])

from sklearn.naive_bayes import GaussianNB
classifier = GaussianNB()
classifier.fit(X, labels)
print(classifier.predict([[-0.8, -1]]))