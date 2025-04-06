//
//  CreatePostView.swift
//  iPost
//
//  Created on 06/04/25.
//

import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var presenter: PostsPresenter
    
    @State private var postText: String = ""
    @State private var selectedImageName: String?
    @State private var showImagePicker = false
    
    // Sample system images for selection
    private let availableImages = [
        "photo", "camera", "car.fill", "airplane", "heart.fill", 
        "star.fill", "figure.hiking", "gamecontroller.fill", "book.fill", 
        "laptopcomputer", "desktopcomputer", "cup.and.saucer.fill", 
        "fork.knife", "music.note", "film", "map", "graduationcap.fill"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Post content
                    TextField("What's on your mind?", text: $postText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .frame(minHeight: 100, alignment: .topLeading)
                }
                
                Section("Add an image") {
                    // Selected image preview
                    if let imageName = selectedImageName {
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .foregroundColor(.accentColor)
                                
                                Button("Remove Image") {
                                    selectedImageName = nil
                                }
                                .foregroundColor(.red)
                                .padding(.top, 8)
                            }
                            Spacer()
                        }
                    } else {
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Label("Select an Image", systemImage: "photo.on.rectangle.angled")
                        }
                    }
                }
                
                // User information
                Section("Posting as") {
                    let currentUser = presenter.users.first(where: { $0.id == presenter.selectedUserId })
                    HStack {
                        Image(systemName: currentUser?.profileImageName ?? "person.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(currentUser?.name ?? "Select a user")
                                .font(.headline)
                            if let username = currentUser?.username {
                                Text(username)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        createPost()
                    }
                    .disabled(postText.isEmpty || presenter.selectedUserId == nil)
                    .bold()
                }
            }
            .sheet(isPresented: $showImagePicker) {
                imagePicker
            }
        }
    }
    
    private var imagePicker: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                    ForEach(availableImages, id: \.self) { imageName in
                        VStack {
                            Image(systemName: imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            
                            Text(imageName)
                                .font(.caption)
                        }
                        .onTapGesture {
                            selectedImageName = imageName
                            showImagePicker = false
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showImagePicker = false
                    }
                }
            }
        }
    }
    
    private func createPost() {
        presenter.createPost(text: postText, imageName: selectedImageName)
        // The presenter will handle closing this sheet after successful creation
    }
}
