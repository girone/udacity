import sys
sys.path.append("../")

from sklearn import svm

from prep_terrain_data import makeTerrainData
from class_vis import prettyPicture, output_image

features_train, labels_train, features_test, labels_test = makeTerrainData()


#classifier = svm.SVC(kernel='linear')
classifier = svm.SVC(kernel='rbf', C=10**5, gamma=10**2)
#classifier = svm.SVC(kernel="poly", C=10**5, gamma=10**5)
classifier.fit(features_train, labels_train)

labels = classifier.predict(features_test)

from sklearn.metrics import accuracy_score
accuracy = accuracy_score(labels, labels_test)


### draw the decision boundary with the text points overlaid
prettyPicture(classifier, features_test, labels_test)
output_image("test.png", "png", open("test.png", "rb").read())




